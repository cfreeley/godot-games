extends CharacterBody2D


const WALK_SPEED = 400.0
const JUMP_VELOCITY = -600.0
var MAX_HSPEED = 1600
const MAX_VSPEED = 1800.0

var pistol = {
  'name': 'P',
  'force': 600,
  'fire_rate': .3,
  'cur_reload': 0
}

var shotgun = {
  name: 'S',
  'force': 1200,
  'fire_rate': 1,
  'cur_reload': 0
}

var loadout = {
  "primary": pistol,
  "secondary": shotgun
}

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var bullet = preload("res://Bullet.tscn")

var direction = 0
var speed = 0
var is_aim_locked = true
var controller_mode = false
var last_aim = Vector2.ZERO
var laser_pos = Vector2.ZERO

func _physics_process(delta):
  # Add the gravity.
  if not is_on_floor():
    velocity.y += gravity * delta

  # Handle Jump.
  if Input.is_action_just_pressed("jump") and is_on_floor():
    velocity.y = JUMP_VELOCITY

  # Get the input direction and handle the movement/deceleration.
  # As good practice, you should replace UI actions with custom gameplay actions.
  direction = Input.get_axis("move_left", "move_right")

  var accel = .1
  var decel = .02 if is_on_floor() else 0.01
  if (direction != 0):
    velocity.x = lerp(velocity.x, direction * max(WALK_SPEED, abs(velocity.x)), accel)
    
  velocity.x = lerp(velocity.x, 0.0, decel)
  
  var space_state = get_world_2d().direct_space_state
  # use global coordinates, not local to node
  var query = PhysicsRayQueryParameters2D.create(global_position, global_position + (get_mouse_angle() * 20000))
  query.exclude = [self]
  var result = space_state.intersect_ray(query)
  if (result.has('position')):
    laser_pos = (result.position - position) * 2
  else:
    laser_pos = get_mouse_angle() * 20000

#1gu = 1/100m. 
  move_and_slide()
  $Camera2D/CanvasLayer/SpeedLabel.text = str("[color=", "green", "]", int(velocity.length()/50))
  velocity.x = clamp(velocity.x, -MAX_HSPEED, MAX_HSPEED)
  velocity.y = clamp(velocity.y, -MAX_VSPEED, MAX_VSPEED)
  
  if (position.y > 800):
    get_parent().emit_signal("player_dead")
  
func _input(event):
    if event is InputEventJoypadMotion:
      controller_mode = true
      var control_dir = Vector2(Input.get_joy_axis(0, JOY_AXIS_RIGHT_X), Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y))
      if (control_dir.length() > .5):
        last_aim = control_dir.normalized()
    elif event is InputEventMouseMotion:
      controller_mode = false

func _process(delta):
    queue_redraw()
    
    var fired_weapon
    if Input.is_action_just_pressed("shoot_primary"):
      print('?')
      fired_weapon = loadout.get("primary")
    elif Input.is_action_just_pressed("shoot_secondary"):
      fired_weapon = loadout.get("secondary")  
    if (fired_weapon and fired_weapon.cur_reload <= 0):
      shoot(fired_weapon)
        
    is_aim_locked = Input.is_action_pressed("toggle_aim_lock")
    
    for weapon in loadout:
      loadout[weapon].cur_reload -= delta

func _draw():
  draw_line(Vector2(0,0), laser_pos, Color.RED)
  draw_line(Vector2(0,0), (get_mouse_angle() * 150), Color.DIM_GRAY, 30)
  
  var i = 0
  for weapon in loadout:
    i += 1

func get_mouse_angle():
  var delta_vel: Vector2 = (get_global_mouse_position()-position).normalized()
  if (controller_mode):
     delta_vel = last_aim
  
  if (is_aim_locked):
    var rounded_angle = round(delta_vel.angle() / (TAU/12)) * (TAU/12)
    return Vector2.RIGHT.rotated((rounded_angle))
  
  return delta_vel
  
func get_net_speed(pspd, bspd):
  pspd=round(pspd)
  bspd=round(bspd)
  
  if (bspd == 0):
    return pspd
  elif (pspd == 0):
    return bspd
  elif (sign(pspd) == sign(bspd)):
    return sign(bspd) * max(abs(bspd), (abs(pspd)))
  else:
    return bspd

func shoot(weapon):
  weapon.cur_reload = weapon.fire_rate
  var delta_vel = get_mouse_angle()
  var impact_vel = delta_vel * -weapon.force
  velocity.x = get_net_speed(velocity.x, impact_vel.x)
  velocity.y = get_net_speed(velocity.y, impact_vel.y)
  $GunExplosion.position = (get_mouse_angle() * 150)
  $GunExplosion.set_power(weapon.force)
  $GunExplosion.emitting = true
  var new_bul = bullet.instantiate()
  new_bul.global_position = global_position + (get_mouse_angle() * 75)
  new_bul.velocity = get_mouse_angle() * (weapon.force / 20)
  get_parent().add_child(new_bul)
