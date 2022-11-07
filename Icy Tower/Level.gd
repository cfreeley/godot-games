extends Node2D

var ZONE_SIZE = 100
var TILE_SIZE = 32

var should_scroll = false
var scroll_speed = 50
var scroll_height = 0
var PLATFORM_SPACING = 3
var zone = -1
var tile_zones = ["Rock", "IcyRock", "LavaRock"]

var random
var wall_tile
var platform_tile
var prev_tile = -1
var next_tile
var Sign = preload("res://Sign.tscn")
var signs = []

func get_platform_tile(z):
	var key = tile_zones[fmod(z,3)]
	return $Platforms/TileMap.tile_set.find_tile_by_name(key)
	
func spawn_zone(z):
	next_tile = get_platform_tile(z)
	
	for n in range(0, ZONE_SIZE):
		var offset = (z * ZONE_SIZE * PLATFORM_SPACING)
		place_platform(n * -PLATFORM_SPACING - offset)
		for m in range(0, PLATFORM_SPACING):
			$Walls/TileMap.set_cell(0, (n * -PLATFORM_SPACING) + m - offset, wall_tile)
			$Walls/TileMap.set_cell(29, (n * -PLATFORM_SPACING) + m - offset, wall_tile)

func _ready():
	get_tree().paused = false
	random = RandomNumberGenerator.new()
	random.randomize()
	wall_tile = $Walls/TileMap.tile_set.find_tile_by_name("Ice")
	for _n in range(0,4):
		var sn = Sign.instance()
		sn.position = Vector2(480, 1000)
		add_child(sn)
		signs.push_back(sn)
		
	spawn_zone(0)
	zone = 0
	spawn_zone(1)
	platform_tile = get_platform_tile(0)
	
func _process(_delta):
	if (Input.is_action_just_pressed("pause")):
		$Menus/Pause/ScoreLabel.text = "Score: " + String($Player.score)
		$Menus/Pause.visible = true
		$Menus/Pause/ResumeButton.grab_focus()
		get_tree().paused = true
		

func place_platform(height = 0):
	var width = random.randi_range(6,12)
	if (fmod(height, ZONE_SIZE/2) == 0):
		width = 28
		var is_new_zone_sign = 1 if fmod(height, ZONE_SIZE) == 0 else 0
		var sign_rotation_index = (zone * 2 + is_new_zone_sign) % signs.size()
		var sn = signs[sign_rotation_index]
		sn.get_node("Board/Label").text = String(height / -PLATFORM_SPACING)
		if (height != 0):
			sn.position.y = (height * TILE_SIZE) + TILE_SIZE / 2
		
	var plat_x = random.randi_range(1, 29-width)
	for n in range(0, width):
		$Platforms/TileMap.set_cell(plat_x + n, height, next_tile)

func _on_Player_died():
	$Menus/GameOver/ScoreLabel.text = "Score: " + String($Player.score)
	$Menus/GameOver/StatsLabel.text = ("Highest Floor: " + String($Player.max_floor) + "\n"
		+ "Highest Combo: " + String($Player.highest_combo))
	$Menus/GameOver.visible = true
	$Menus/GameOver/RetryButton.grab_focus()
	get_tree().paused = true

func _on_Player_new_zone():
	if (prev_tile != -1):
		var old = $Platforms/TileMap.get_used_cells_by_id(prev_tile)
		for tile in old:
			$Platforms/TileMap.set_cell(tile[0], tile[1], -1)
		for n in range(0, ZONE_SIZE * PLATFORM_SPACING):
			var offset = (zone * ZONE_SIZE * PLATFORM_SPACING)
			$Walls/TileMap.set_cell(0, n - offset, -1)
			$Walls/TileMap.set_cell(29, n - offset, -1)
	zone += 1
	prev_tile = platform_tile
	platform_tile = next_tile
	spawn_zone(zone + 1)
	var BG = $Background/ParallaxLayer/Sprite
	BG.get_node("Tween").interpolate_property(BG, "modulate:s", null, float(zone) / 20, 3)
	BG.get_node("Tween").interpolate_property(BG, "modulate:v", null, 1 - (float(zone) / 40), 3)
	BG.get_node("Tween").start()


func _on_QuitButton_pressed():
	get_tree().quit()

func _on_ResumeButton_pressed():
	$Menus/Pause.visible = false
	get_tree().paused = false


func _on_RestartButton_pressed():
	get_tree().reload_current_scene()

func _on_RetryButton_pressed():
	get_tree().reload_current_scene()
