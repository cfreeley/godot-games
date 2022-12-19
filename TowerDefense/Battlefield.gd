extends Node2D

var Enemy = preload("res://Enemy.tscn")
var Tower = preload("res://Tower.tscn")

var held_tower = null
var is_mouse_pressed = false

var count = 0

func _draw():
	draw_polyline($EnemyPath.curve.get_baked_points(), Color.yellowgreen, 4, true)
	if (held_tower):
		draw_texture($Preview.texture, held_tower.position - Vector2(32,32), Color(1, 1, 1, .5))
		draw_circle(held_tower.position, held_tower.get_node("Radius/CollisionShape2D").shape.radius, Color(0, 0, 1, .1))

func _on_SpawnTimer_timeout():
	spawn()
	$SpawnTimer.wait_time = 2.0 - (2 * ((count*count)/(2500.0+(count*count)))) #sigmoid
	count += 1

func spawn():
	var en = Enemy.instance()
	$EnemyPath.add_child(en)


func _on_Area2D_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton and is_mouse_pressed and !event.is_pressed()):
		add_child(held_tower)
		held_tower = null
		is_mouse_pressed = false
		update()
	elif (event.is_pressed()):
		is_mouse_pressed = true
	
	if (is_mouse_pressed):
		held_tower = Tower.instance()
		held_tower.position = event.position
		update()
