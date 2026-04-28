extends Control

const MAX_LINES := 12

var _lines: Array[String] = []
var _label: Label
var _bg: ColorRect

func _ready() -> void:
	_build_visual()
	GameManager.log_message.connect(_add_line)

func _build_visual() -> void:
	_bg = ColorRect.new()
	_bg.color = Color(0.06, 0.06, 0.08)
	_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_bg)

	_label = Label.new()
	_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_label.add_theme_font_size_override("font_size", 9)
	_label.modulate = Color(0.7, 0.75, 0.7)
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	add_child(_label)

func _add_line(text: String) -> void:
	_lines.append(text)
	if _lines.size() > MAX_LINES:
		_lines = _lines.slice(_lines.size() - MAX_LINES)
	_label.text = "\n".join(_lines)
