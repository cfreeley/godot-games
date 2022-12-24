extends Node2D

var need_reload = false
var target = null
var Bullet = preload("res://Bullet.tscn")
export var cost = 200
export var radius = 90
export var damage = 100
export var fire_rate = .25

func _ready():
	$Radius/CollisionShape2D.shape.radius = radius
	$Timer.wait_time = fire_rate

func _on_Timer_timeout():
	need_reload = false

func _physics_process(delta):
	aim_and_shoot()

func aim_and_shoot():
	if (need_reload):
		return 
	
	if (target == null):
		for body in $Radius.get_overlapping_areas():
			if body.owner and body.owner.is_in_group("enemy"):
				target = body
		return;

	
	var bul = Bullet.instance()
	add_child(bul)
	bul.direction = (target.global_position-global_position).normalized()
	bul.damage = damage
	need_reload = true
	$Timer.start()

func _on_Radius_area_exited(area):
	if (area == target):
		target = null
