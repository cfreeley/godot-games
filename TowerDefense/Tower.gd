extends Node2D

var need_reload = false
var target = null
var Bullet = preload("res://Bullet.tscn")

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
	need_reload = true
	$Timer.start()

func _on_Radius_area_exited(area):
	if (area == target):
		target = null
