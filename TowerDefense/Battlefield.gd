extends Node2D

var Enemy = preload("res://Enemy.tscn")
var Tower = preload("res://Tower.tscn")

var held_tower = null
var is_mouse_pressed = false

var money = 200
var kills = 0
var spawns = 0
var cur_round = 0
var in_round = false

var base_dam = 100.0
var base_cost = 200.0
var base_fire_rate = .75
var base_dps = base_dam / base_fire_rate
var wave_length = 15.0
var base_en_health = base_dam * 4.0
var total_en_str = base_dps * wave_length
var num_enemies = total_en_str / base_en_health
var spawn_period = wave_length / num_enemies
var base_en_reward = round (base_cost / num_enemies)

func _draw():
	draw_polyline($EnemyPath.curve.get_baked_points(), Color.yellowgreen, 4, true)
	if (held_tower):
		draw_texture($Preview.texture, held_tower.position - Vector2(32,32), Color(1, 1, 1, .5))
		var aura_color = Color.blue if held_tower.cost <= money else Color.red
		aura_color.a = .1
		draw_circle(held_tower.position, held_tower.radius, aura_color)

func start_wave():
	in_round = true
	$SpawnTimer.start(spawn_period)
	$WaveTimer.start(wave_length)
	$CanvasLayer/PhaseLabel.text = "Phase: Defend"
	$CanvasLayer/PhaseStatus.color = Color.red

func end_wave():
	$CanvasLayer/PhaseLabel.text = "Phase: Build"
	$CanvasLayer/PhaseStatus.color = Color.green

func spawn():
	var en = Enemy.instance()
	en.health = base_en_health
	en.reward = base_en_reward
	$EnemyPath.add_child(en)

func buy_tower():
	if (held_tower.cost <= money):
		money -= held_tower.cost
		held_tower.damage = base_dam
		held_tower.fire_rate = base_fire_rate
		add_child(held_tower)

func _on_Area2D_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton and is_mouse_pressed and !event.is_pressed()):
		buy_tower()
		held_tower = null
		is_mouse_pressed = false
		update()
	elif (event.is_pressed()):
		is_mouse_pressed = true
	
	if (is_mouse_pressed):
		held_tower = Tower.instance()
		held_tower.position = event.position
		held_tower.cost = base_cost
		update()
		
func _process(delta):
	update_label()
		
func update_label():
	$CanvasLayer/StatsLabel.text = str("Money: ", money, "\nKills: ", kills)

func _on_NextWaveButton_pressed():
	start_wave()

func _on_SpawnTimer_timeout():
	if (in_round):
		spawn()
	elif (get_tree().get_nodes_in_group("enemy").size() == 0):
		$SpawnTimer.stop()
		end_wave()
	else:
		get_tree().get_nodes_in_group("enemy").size()
	# $SpawnTimer.wait_time = 2.0 - (2 * ((spawns*spawns)/(2500.0+(spawns*spawns)))) #sigmoid
	# spawns += 1


func _on_WaveTimer_timeout():
	in_round = false
