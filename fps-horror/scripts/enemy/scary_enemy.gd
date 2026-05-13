extends CharacterBody3D
class_name ScaryEnemy

## ScaryEnemy — Weeping Angel mechanic.
## Moves toward the player only when the player is NOT looking at it.
## The moment it enters the camera's view frustum it freezes completely.
## If it reaches the player the GameManager is told the player is caught.

# ---------------------------------------------------------------------------
# Exports
# ---------------------------------------------------------------------------

@export var move_speed: float     = 1.8   ## Units per second while unseen
@export var rotation_speed: float = 6.0   ## Facing-the-player slerp factor
@export var catch_distance: float = 1.1   ## Distance that counts as "caught"

# ---------------------------------------------------------------------------
# State
# ---------------------------------------------------------------------------

var _player: Node3D   = null
var _camera: Camera3D = null
var _frozen: bool     = false   ## True while the player can see us
var _caught: bool     = false   ## True once the player has been caught

# Torso offset so the visibility check tests mid-body rather than feet,
# which dip behind low cover first.
const TORSO_OFFSET := Vector3(0, 1.2, 0)
const GRAVITY      := 9.8


# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	call_deferred("_find_player")


func _find_player() -> void:
	var player_node := get_tree().get_first_node_in_group("player")
	if player_node == null:
		push_warning("ScaryEnemy: no node in group 'player' — enemy disabled.")
		set_physics_process(false)
		return
	_player = player_node
	_camera = _player.get_node_or_null("Head/Camera3D")
	if _camera == null:
		push_warning("ScaryEnemy: Camera3D not found at Head/Camera3D — enemy disabled.")
		set_physics_process(false)


func _physics_process(delta: float) -> void:
	# Always apply gravity so the enemy rides the floor properly.
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = 0.0

	if _player == null or _camera == null or _caught:
		move_and_slide()
		return

	# -----------------------------------------------------------------------
	# Visibility — is the torso inside the camera frustum?
	# -----------------------------------------------------------------------
	var world_torso := global_position + TORSO_OFFSET
	_frozen = _camera.is_position_in_frustum(world_torso)

	if _frozen:
		# Snap horizontal velocity to zero while watched.
		velocity.x = 0.0
		velocity.z = 0.0
	else:
		var to_player := _player.global_position - global_position
		var flat_dir  := Vector3(to_player.x, 0.0, to_player.z).normalized()

		# Smoothly face the player
		if flat_dir.length_squared() > 0.001:
			var target_basis := Basis.looking_at(flat_dir, Vector3.UP)
			transform.basis   = transform.basis.slerp(target_basis, rotation_speed * delta)

		velocity.x = flat_dir.x * move_speed
		velocity.z = flat_dir.z * move_speed

		# Catch check
		if to_player.length() <= catch_distance:
			_caught        = true
			velocity       = Vector3.ZERO
			GameManager.change_state(GameManager.State.CAUGHT)

	move_and_slide()
