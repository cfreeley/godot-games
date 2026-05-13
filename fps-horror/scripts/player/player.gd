extends CharacterBody3D

## Player — First-person character controller
## Handles: WASD movement, mouse look, sprinting, crouching,
## head bob, FOV transitions, and interaction raycast.

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

const WALK_SPEED    := 3.0
const SPRINT_SPEED  := 5.5
const CROUCH_SPEED  := 1.5
const GRAVITY       := 9.8

const MOUSE_SENSITIVITY := 0.002

# Head bob
const BOB_FREQUENCY          := 2.0
const BOB_AMPLITUDE          := 0.04
const BOB_SPRINT_MULTIPLIER  := 1.5

# FOV
const FOV_DEFAULT := 75.0
const FOV_SPRINT  := 83.0
const FOV_CROUCH  := 68.0
const FOV_LERP    := 8.0

# Crouch — head Y positions and collision heights
const HEAD_STAND_Y  := 1.6
const HEAD_CROUCH_Y := 0.85
const CROUCH_TWEEN_TIME := 0.15

# Interaction
const INTERACTION_DISTANCE := 2.5

# ---------------------------------------------------------------------------
# Exports (designer-tweakable in editor)
# ---------------------------------------------------------------------------

@export var walk_speed: float        = WALK_SPEED
@export var sprint_speed: float      = SPRINT_SPEED
@export var mouse_sensitivity: float = MOUSE_SENSITIVITY

# ---------------------------------------------------------------------------
# Node refs
# ---------------------------------------------------------------------------

@onready var head: Node3D               = $Head
@onready var camera: Camera3D           = $Head/Camera3D
@onready var interaction_ray: RayCast3D = $Head/InteractionRay
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var flashlight: SpotLight3D    = $Head/Flashlight
@onready var hold_point: Node3D         = $Head/Camera3D/HoldPoint
@onready var footstep_audio: AudioStreamPlayer3D = $FootstepAudio

# ---------------------------------------------------------------------------
# State
# ---------------------------------------------------------------------------

## Emitted whenever the interactable the player is looking at changes.
signal interaction_target_changed(prompt: String, visible: bool)

var _pitch: float         = 0.0
var _bob_time: float      = 0.0
var _is_sprinting: bool   = false
var _is_crouching: bool   = false
var _current_speed: float = WALK_SPEED
var _current_interactable: Node = null
var _crouch_tween: Tween  = null

## Currently held item (held in front of the camera via HoldPoint)
var _held_item: HoldableItem = null

## Tween that slides the item into hold position — must be killed on early drop
var _pickup_tween: Tween = null

## Cached HUD reference found via "hud" group
var _hud: Node = null

## Footstep state
var _step_timer: float            = 0.0   # counts down; fires a step when it hits 0
var _footstep_stream: AudioStreamWAV = null

const STEP_INTERVAL_WALK   := 0.48
const STEP_INTERVAL_SPRINT := 0.32
const STEP_INTERVAL_CROUCH := 0.65


# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
  # Must process even when the tree is paused so Escape can un-pause.
  # (GameManager sets get_tree().paused = true, which would otherwise silence
  # all input on this node's default PROCESS_MODE_INHERIT.)
  process_mode = Node.PROCESS_MODE_ALWAYS
  Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
  add_to_group("player")
  call_deferred("_find_hud")
  _footstep_stream = _generate_footstep_stream()
  footstep_audio.stream = _footstep_stream
  footstep_audio.unit_size = 1.0
  footstep_audio.max_distance = 8.0


func _find_hud() -> void:
  _hud = get_tree().get_first_node_in_group("hud")


func _unhandled_input(event: InputEvent) -> void:
  if event is InputEventMouseMotion:
    # Use mouse mode as the gating signal — it's set explicitly on pause/unpause
    # and is more reliable than querying game state here.
    if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and not GameManager.is_hiding():
      _handle_mouse_look(event.relative)
    return  # Motion events don't support is_action_pressed — bail out here

  # Pause toggle MUST be processed even while paused — it's what unpauses.
  # All other actions are gated below.
  if event.is_action_pressed("pause"):
    _toggle_pause()
    return

  if GameManager.current_state == GameManager.State.PAUSED:
    return

  # Flashlight toggle — right click
  if event.is_action_pressed("flashlight"):
    flashlight.visible = not flashlight.visible

  # Hold / drop — left click
  if event.is_action_pressed("pick_up_hold"):
    if _held_item != null:
      _drop_held_item()
    elif interaction_ray.is_colliding():
      var collider := interaction_ray.get_collider()
      if collider is HoldableItem:
        _pick_up_item(collider)


func _physics_process(delta: float) -> void:
  if GameManager.current_state == GameManager.State.PAUSED:
    return

  _apply_gravity(delta)

  if not GameManager.is_hiding():
    _handle_movement(delta)
    _handle_crouch()
    _update_head_bob(delta)
    _update_camera_fov(delta)

  _check_interaction()
  move_and_slide()


# ---------------------------------------------------------------------------
# Input handlers
# ---------------------------------------------------------------------------

func _handle_mouse_look(relative: Vector2) -> void:
  rotate_y(-relative.x * mouse_sensitivity)
  _pitch = clamp(_pitch - relative.y * mouse_sensitivity, -PI / 2.2, PI / 2.2)
  head.rotation.x = _pitch


func _toggle_pause() -> void:
  if GameManager.current_state == GameManager.State.PAUSED:
    GameManager.resume_game()
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
  else:
    GameManager.pause_game()
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


# ---------------------------------------------------------------------------
# Movement
# ---------------------------------------------------------------------------

func _apply_gravity(delta: float) -> void:
  if not is_on_floor():
    velocity.y -= GRAVITY * delta
  else:
    velocity.y = 0.0


func _handle_movement(_delta: float) -> void:
  _is_sprinting = Input.is_action_pressed("sprint") and not _is_crouching
  _current_speed = (
    sprint_speed if _is_sprinting
    else CROUCH_SPEED if _is_crouching
    else walk_speed
  )

  var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
  var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

  if direction:
    velocity.x = direction.x * _current_speed
    velocity.z = direction.z * _current_speed
  else:
    velocity.x = move_toward(velocity.x, 0, _current_speed)
    velocity.z = move_toward(velocity.z, 0, _current_speed)


func _handle_crouch() -> void:
  if not Input.is_action_just_pressed("crouch"):
    return

  _is_crouching = not _is_crouching
  var target_y := HEAD_CROUCH_Y if _is_crouching else HEAD_STAND_Y

  if _crouch_tween:
    _crouch_tween.kill()
  _crouch_tween = create_tween()
  _crouch_tween.tween_property(head, "position:y", target_y, CROUCH_TWEEN_TIME)


# ---------------------------------------------------------------------------
# Camera effects
# ---------------------------------------------------------------------------

func _update_head_bob(delta: float) -> void:
  var is_moving := velocity.length() > 0.2 and is_on_floor()
  if is_moving:
    var mult := BOB_SPRINT_MULTIPLIER if _is_sprinting else 1.0
    _bob_time += delta * BOB_FREQUENCY * mult
    camera.position.y = sin(_bob_time) * BOB_AMPLITUDE

    # Independent step timer — decoupled from bob speed so cadence feels right.
    _step_timer -= delta
    if _step_timer <= 0.0:
      _play_footstep()
      _step_timer = (
        STEP_INTERVAL_SPRINT if _is_sprinting
        else STEP_INTERVAL_CROUCH if _is_crouching
        else STEP_INTERVAL_WALK
      )
  else:
    _bob_time = 0.0
    _step_timer = 0.0   # reset so the first step fires immediately on next move
    camera.position.y = move_toward(camera.position.y, 0.0, delta * 5.0)


## Play a single footstep sound with slight pitch variation.
func _play_footstep() -> void:
  if footstep_audio == null or _footstep_stream == null:
    return
  # Randomise pitch slightly so each step sounds different.
  var base_pitch := 1.1 if _is_sprinting else 1.0
  footstep_audio.pitch_scale = base_pitch + randf_range(-0.06, 0.06)
  footstep_audio.play()


## Build a short procedural footstep WAV (thump + noise burst, ~110 ms).
## Called once in _ready so it is reused for every step.
func _generate_footstep_stream() -> AudioStreamWAV:
  const SAMPLE_RATE := 22050
  const DURATION    := 0.11   # seconds
  var num_samples   := int(SAMPLE_RATE * DURATION)

  var data := PackedByteArray()
  data.resize(num_samples * 2)  # 16-bit mono

  for i in range(num_samples):
    var t       := float(i) / SAMPLE_RATE
    # Low-frequency thump (around 65 Hz), decays quickly.
    var thump   := sin(TAU * 65.0 * t) * exp(-t * 28.0) * 0.45
    # Broadband noise burst for the click/impact transient.
    var noise   := randf_range(-1.0, 1.0) * exp(-t * 55.0) * 0.30
    var sample  := clampf(thump + noise, -1.0, 1.0)
    var s16     := int(sample * 32767)
    data[i * 2]     = s16 & 0xFF
    data[i * 2 + 1] = (s16 >> 8) & 0xFF

  var wav         := AudioStreamWAV.new()
  wav.data        = data
  wav.format      = AudioStreamWAV.FORMAT_16_BITS
  wav.mix_rate    = SAMPLE_RATE
  wav.stereo      = false
  return wav


func _update_camera_fov(delta: float) -> void:
  var target := FOV_SPRINT if _is_sprinting else (FOV_CROUCH if _is_crouching else FOV_DEFAULT)
  camera.fov = lerp(camera.fov, target, delta * FOV_LERP)


# ---------------------------------------------------------------------------
# Interaction (E key — inventory pickups, doors, switches, hiding spots)
# ---------------------------------------------------------------------------

func _check_interaction() -> void:
  if interaction_ray.is_colliding():
    var collider := interaction_ray.get_collider()

    if collider != _current_interactable:
      _current_interactable = collider
      if collider.has_method("get_interaction_prompt"):
        var prompt: String = collider.get_interaction_prompt()
        emit_signal("interaction_target_changed", prompt, true)
        if _hud:
          _hud.show_interaction_prompt(prompt)
      else:
        emit_signal("interaction_target_changed", "", false)
        if _hud:
          _hud.hide_interaction_prompt()

    if Input.is_action_just_pressed("interact"):
      if collider.has_method("interact"):
        collider.interact(self)
  else:
    if _current_interactable != null:
      _current_interactable = null
      emit_signal("interaction_target_changed", "", false)
      if _hud:
        _hud.hide_interaction_prompt()


# ---------------------------------------------------------------------------
# Hold / Drop (left click — papers, props, inspectable objects)
# ---------------------------------------------------------------------------

func _pick_up_item(item: HoldableItem) -> void:
  _held_item = item

  # Stop the item from being detected by the ray while held
  interaction_ray.add_exception(_held_item)

  # Disable physics and attach to the hold point
  _held_item.freeze = true
  _held_item.reparent(hold_point, true)

  # Smoothly slide into the hold position — stored so we can kill it on early drop
  if _pickup_tween:
    _pickup_tween.kill()
  # Tilt the paper toward the camera so the player can read it while holding it.
  # PlaneMesh normal is +Y; +70° around X rotates that face to point back toward the camera.
  var hold_rot := Vector3(deg_to_rad(70.0), 0.0, 0.0)
  _pickup_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
  _pickup_tween.tween_property(_held_item, "position", Vector3.ZERO, 0.2)
  _pickup_tween.parallel().tween_property(_held_item, "rotation", hold_rot, 0.2)

  if _hud:
    _hud.show_held_prompt(_held_item.item_name)
    if _held_item.readable_text != "":
      _hud.show_reading_text(_held_item.readable_text)


func _drop_held_item() -> void:
  if _held_item == null:
    return

  var item := _held_item
  _held_item = null

  # Kill the pickup tween before reparenting — if it's still running it will
  # continue driving the item's local position toward Vector3.ZERO, which after
  # reparent means world origin, teleporting the paper into the floor.
  if _pickup_tween:
    _pickup_tween.kill()
    _pickup_tween = null

  # Re-enable physics and return to scene root
  item.reparent(get_tree().current_scene, true)

  # Strip any camera pitch/roll baked in from HoldPoint — keep only yaw so the
  # paper is always level when it drops, regardless of where the player was looking.
  item.global_rotation = Vector3(0.0, item.global_rotation.y, 0.0)

  item.freeze = false
  # reparent() can silently reset physics body properties — restore everything
  item.continuous_cd = true
  item.apply_physics_settings()

  # No throw — just let it drop straight down.
  item.linear_velocity  = Vector3.ZERO
  item.angular_velocity = Vector3.ZERO

  interaction_ray.remove_exception(item)

  if _hud:
    _hud.hide_held_prompt()
    _hud.hide_reading_text()
