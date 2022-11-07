extends KinematicBody2D

var GRAVITY = 1000
var INITIAL_WALK_SPEED = 300
var WALK_ACCEL = 400
var WALK_DECEL = 400
var AERIAL_DECEL = 50

var JUMP_SPEED = 600
var DOUBLE_JUMP_SPEED = 500

var MAX_X_VEL = 1000
var MAX_Y_VEL = 1400

var has_double_jumped = false
var fast_falling = 0 # ratio 0 to 1
var velocity = Vector2()

func move_and_bounce():
	var old_vel = velocity
	velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)
	
	if (fast_falling > 0 and old_vel.y > velocity.y):
		velocity.y = -old_vel.y
	
	if (is_on_wall() 
		and not Input.is_action_pressed("ui_left")
		and not Input.is_action_pressed("ui_right")):
		velocity.x = old_vel.x * -1
	

func _physics_process(delta):
	if Input.is_action_pressed("ui_left"):
		velocity.x = min(velocity.x, -INITIAL_WALK_SPEED) - (WALK_ACCEL * delta)
	elif Input.is_action_pressed("ui_right"):
		velocity.x = max(velocity.x, INITIAL_WALK_SPEED) + (WALK_ACCEL * delta)
	else: # decellerate
		var decel = WALK_DECEL if is_on_floor() else AERIAL_DECEL
		if (velocity.x > 0):
			velocity.x = max(0, velocity.x - (decel * delta))
		else:
			velocity.x = min(0, velocity.x + (decel * delta))
			
		
	if (is_on_floor()):
		has_double_jumped = false
		rotation = 0
	elif (has_double_jumped and velocity.x != 0):
		print(velocity.y)
		rotation += 15 * delta * (velocity.x / abs(velocity.x))
		
	if (Input.is_action_just_pressed("ui_up")):
		if (is_on_floor()):
			velocity.y = -JUMP_SPEED
		elif (velocity.y > -DOUBLE_JUMP_SPEED and (not has_double_jumped or is_on_wall())):
			$DoubleJumpDust.emitting = true
			velocity.y = -DOUBLE_JUMP_SPEED
			has_double_jumped = true	
			
	fast_falling = 1 if Input.is_action_pressed("ui_down") else max(fast_falling-(5*delta), 0)
	$FastFallParticles.emitting = fast_falling > 0 and velocity.y > 0

	var gravity = GRAVITY if fast_falling == 0 else GRAVITY * 2
	velocity.y += delta * gravity
	
	move_and_bounce()
	
	velocity.x = clamp(velocity.x, -MAX_X_VEL, MAX_X_VEL)
	velocity.y = clamp(velocity.y, -MAX_Y_VEL, MAX_Y_VEL)


func _on_Respawn_pressed():
	position = Vector2(300,0)
