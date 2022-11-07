extends Node2D

export(int) var GRID_W = 1
export(int) var GRID_H = 1

export(Array, String) var actions = []
export(String) var obj_name = ""
export(String) var obj_desc = ""

var is_highlited = false
var bounding_rect

func toggle_highlite(val = true):
	is_highlited = val
	update()

func _draw():
	if (is_highlited):
		draw_rect(Rect2(-bounding_rect / 2, bounding_rect), Color.yellow, false)

func _ready():
	bounding_rect = Vector2(GRID_W * Game.CELL_LEN, GRID_H * Game.CELL_LEN)
	var offset = Vector2(1,1)
	$Body/CollisionShape2D.shape.extents = bounding_rect / 2

func _on_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton and event.pressed):
		if (event.button_index == BUTTON_LEFT):
			Game.click_object(event, self, obj_name, obj_desc)
		elif (event.button_index == BUTTON_RIGHT):
			Game.open_actions(event, self, actions)

