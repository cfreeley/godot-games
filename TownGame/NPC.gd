extends "res://Tile.gd"

export(Array, DIRECTION) var WALK_PATH
export(Array, String) var DIALOGUE
var move_idx = 0

func _ready():
	$Sprite.modulate.h = randf()
	$Sprite.modulate.s = .7
	$Sprite.modulate.v = 1.2

func _process(delta):
	pass

func interact(_player):
	return ['dialogue', DIALOGUE]

func _on_WalkTimer_timeout():
	var move = WALK_PATH[move_idx % WALK_PATH.size()]

	if (move_from_dir(move)):
		move_idx += 1
