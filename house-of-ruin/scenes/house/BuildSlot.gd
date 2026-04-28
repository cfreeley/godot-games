extends Control

# Visual only — click detection handled by HouseBoard._unhandled_input
# to avoid Camera2D coordinate transform issues with Control._gui_input

const TILE_W := 114
const TILE_H := 94

var grid_pos: Vector2i = Vector2i.ZERO

func _ready() -> void:
	custom_minimum_size = Vector2(TILE_W, TILE_H)
	size = Vector2(TILE_W, TILE_H)
	mouse_filter = MOUSE_FILTER_IGNORE  # HouseBoard handles clicks
	_build_visual()

func _build_visual() -> void:
	var bg := ColorRect.new()
	bg.size = Vector2(TILE_W, TILE_H)
	bg.color = Color(0.25, 0.45, 0.25, 0.35)
	bg.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(bg)

	for rect_def: Array in [
		[Vector2(0, 0),          Vector2(TILE_W, 2)],
		[Vector2(0, TILE_H - 2), Vector2(TILE_W, 2)],
		[Vector2(0, 0),          Vector2(2, TILE_H)],
		[Vector2(TILE_W - 2, 0), Vector2(2, TILE_H)],
	]:
		var border := ColorRect.new()
		border.position = rect_def[0]
		border.size = rect_def[1]
		border.color = Color(0.4, 0.8, 0.4, 0.7)
		border.mouse_filter = MOUSE_FILTER_IGNORE
		add_child(border)

	var plus := Label.new()
	plus.text = "+"
	plus.add_theme_font_size_override("font_size", 36)
	plus.modulate = Color(0.5, 0.9, 0.5, 0.8)
	plus.position = Vector2(TILE_W / 2.0 - 14, TILE_H / 2.0 - 22)
	plus.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(plus)

func setup(pos: Vector2i) -> void:
	grid_pos = pos
