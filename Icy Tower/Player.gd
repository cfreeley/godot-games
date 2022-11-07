extends KinematicBody2D

var GRAVITY = 2000
var INITIAL_WALK_SPEED = 200
var WALK_ACCEL = 700
var TURN_ACCEL = 2000
var WALK_DECEL = 400
var AERIAL_DECEL = 50
var TRICK_THRESHOLD = 1200
var BOOST_THRESHOLD = 50

var JUMP_SPEED = 600
var MAX_BOOST_JUMP_SPEED = 2000
var JETPACK_SPEED = 1800
#var DOUBLE_JUMP_SPEED = 500

var MAX_X_VEL = 1600
var MAX_Y_VEL = 2400

var has_double_jumped = false
var boost_meter = 0
var fast_falling = 0 # ratio 0 to 1
var is_tricking = false
var max_floor = 0
var current_zone = 0
var current_combo = 0
var score = 0
var highest_combo = 0
var camera_speed = 0
var current_camera_scroll = 0
var velocity = Vector2()

var VIEWPORT_HEIGHT
var SPRITE_HEIGHT

signal died
signal new_zone

func _ready():
	VIEWPORT_HEIGHT = get_viewport().get_visible_rect().size.y
	SPRITE_HEIGHT = $Sprite.texture.get_size().y
	
func _process(delta):
	$HUD/Control/Combo.modulate.h += .5 * delta

func move_and_bounce():
	var old_vel = velocity
	velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)
	
	if (fast_falling > 0 and old_vel.y > velocity.y):
		velocity.y = -old_vel.y - (get_boost_jump() / 2)
	
	if (is_on_wall()):
		velocity.x = -old_vel.x

func get_boost_jump():
	if (velocity.x == 0):
		return 0
	return (abs(velocity.x) / MAX_X_VEL) * (MAX_BOOST_JUMP_SPEED - JUMP_SPEED)
	
func check_boost():
	if (boost_meter < BOOST_THRESHOLD):
		$Sprite.modulate = Color.white	

func score_combo():
	var combo_score = current_combo * current_combo
	$HUD/Control/ComboEnd.text = "Nice!\n+" + String(combo_score)
	$HUD/Control/ComboEnd/Tween.interpolate_property($HUD/Control/ComboEnd, 
		'rect_position', Vector2(0,1200), Vector2(0,300), .25)
	$HUD/Control/ComboEnd/Tween.interpolate_property($HUD/Control/ComboEnd, 
		'modulate:h', 0, .8, 1)
	$HUD/Control/ComboEnd/Tween.interpolate_property($HUD/Control/ComboEnd, 
		'modulate:a', 1, 0, 2)
	$HUD/Control/ComboEnd/Tween.start()
	$HUD/Control/Combo.visible = false

	score += current_combo * current_combo
	highest_combo = max(highest_combo, current_combo)
	current_combo = 0
	boost_meter = 0
	check_boost()

func _physics_process(delta):
	var direction = 0
	if Input.is_action_pressed("ui_left"):
		direction = -1
	elif Input.is_action_pressed("ui_right"):
		direction = 1

	if (direction == 0): # decellerate
		var decel = WALK_DECEL if is_on_floor() else AERIAL_DECEL
		if (velocity.x > 0):
			velocity.x = max(0, velocity.x - (decel * delta))
		else:
			velocity.x = min(0, velocity.x + (decel * delta))
	else:
		if (velocity.x == 0):
			velocity.x = INITIAL_WALK_SPEED * direction
		else:
			var old_dir = velocity.x / abs(velocity.x)
			if (direction == old_dir):
				velocity.x += WALK_ACCEL * direction * delta
			else:
				velocity.x += TURN_ACCEL * direction * delta
			
	if (is_on_floor()):
		is_tricking = false
		has_double_jumped = false
		$Sprite.rotation = 0
		$Sprite/TrickParticles.emitting = false
		var platform = get_last_slide_collision()
		if (platform and platform.collider):
			var current_floor = round((platform.collider.position.y - position.y) / 96)
			if (floor(current_floor / 100) > current_zone):
				emit_signal("new_zone")
				current_zone += 1
				
			if (current_floor >= 2):
				$Camera.smoothing_enabled = true
				camera_speed = (floor(current_floor / 50) * 5) + 50
				
			if (max_floor != current_floor):
				var floor_delta = current_floor - max_floor
				if (floor_delta >= 2):
					current_combo += floor_delta
					$HUD/Control/Combo.visible = true
					$HUD/Control/Combo.text = String(current_combo) + "x Combo!"
					boost_meter += floor_delta
					if (boost_meter >= BOOST_THRESHOLD and boost_meter - floor_delta < BOOST_THRESHOLD):
						var blabel = $HUD/Control/BoostAvailable;
						blabel.visible = true
						blabel.get_node("Tween").interpolate_property(blabel, "modulate:a", 1, 0, 2)
						blabel.get_node("Tween").start()
						$Sprite.modulate = Color.red
							
				elif (current_combo > 0):
					score_combo()

				score += floor_delta * 10
				$HUD/Control/Score.text = "Score " + String(score)
				max_floor = current_floor
				
	

	if (is_tricking):
		$Sprite.rotation += 15 * delta * (velocity.x / max(abs(velocity.x), 1))
	
	if (direction != 0):
		$AnimatedSprite.flip_h = false if direction == 1 else true 
		
	if (Input.is_action_pressed("jump")):
		if (is_on_floor()):
			var boost_speed = get_boost_jump()
			velocity.y = -JUMP_SPEED -boost_speed
			is_tricking = -velocity.y > TRICK_THRESHOLD
			if (is_tricking):
				$Sprite/TrickParticles.emitting = true
				$TrickSound.play()
			else:
				$JumpSound.play()
	
	if (Input.is_action_pressed("power") and boost_meter >= BOOST_THRESHOLD):
		velocity.y = min(-JETPACK_SPEED, velocity.y - JETPACK_SPEED)
		$BoostParticles.emitting = true
		is_tricking = false
		$Sprite/TrickParticles.emitting = false
		$Sprite.rotation = 0
		$BoostSound.play()
		
		boost_meter -= BOOST_THRESHOLD
		check_boost()
			
#	fast_falling = 1 if Input.is_action_pressed("ui_down") else max(fast_falling-(5*delta), 0)
	$FastFallParticles.emitting = fast_falling > 0 and velocity.y > 0

	var gravity = GRAVITY if fast_falling == 0 else GRAVITY * 2
	velocity.y += delta * gravity
	
	move_and_bounce()
	
	velocity.x = clamp(velocity.x, -MAX_X_VEL, MAX_X_VEL)
	velocity.y = clamp(velocity.y, -MAX_Y_VEL, MAX_Y_VEL)
	$Camera.limit_bottom = min($Camera.limit_bottom, position.y + (VIEWPORT_HEIGHT * .75))
	$AnimatedSprite.speed_scale = abs(velocity.x) / (MAX_X_VEL / 20) 
	$AnimatedSprite.rotation = $Sprite.rotation
	
	# camera bottom is an int so decimals need to be tracked separately
	current_camera_scroll += camera_speed * delta
	$Camera.limit_bottom -= current_camera_scroll
	current_camera_scroll -= floor(current_camera_scroll)
	
	if (position.y - $Camera.get_camera_screen_center().y 
		> (VIEWPORT_HEIGHT/2) + (SPRITE_HEIGHT/2)):
		score_combo()
		$HUD/Control.visible = false
		emit_signal("died")
