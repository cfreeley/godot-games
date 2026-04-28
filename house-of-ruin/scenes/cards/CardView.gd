extends Control

signal card_played(card: CardData)

const CARD_W := 120
const CARD_H := 180

var card_data: CardData = null

# _visual is a child that gets scaled on hover — the parent Control
# never moves or resizes, so hit area stays stable
var _visual: Control
var _rarity_bar: ColorRect
var _produces_label: RichTextLabel
var _art_rect: ColorRect
var _name_label: Label
var _desc_label: Label
var _play_btn: Button

var _hovered: bool = false

func _ready() -> void:
	custom_minimum_size = Vector2(CARD_W, CARD_H)
	size = Vector2(CARD_W, CARD_H)
	mouse_filter = MOUSE_FILTER_STOP
	_build_visual()

func _process(_delta: float) -> void:
	var mouse := get_global_mouse_position()
	var inside := _visual.get_global_rect().has_point(mouse)
	if inside and not _hovered:
		_hovered = true
		_on_hover_start()
	elif not inside and _hovered:
		_hovered = false
		_on_hover_end()

func _build_visual() -> void:
	# All visual children live inside _visual so animations don't affect
	# the parent's hit area
	_visual = Control.new()
	_visual.size = Vector2(CARD_W, CARD_H)
	_visual.pivot_offset = Vector2(CARD_W / 2.0, CARD_H / 2.0)
	_visual.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(_visual)

	var bg := ColorRect.new()
	bg.position = Vector2.ZERO
	bg.size = Vector2(CARD_W, CARD_H)
	bg.color = Color(0.16, 0.16, 0.20)
	bg.mouse_filter = MOUSE_FILTER_IGNORE
	_visual.add_child(bg)

	_rarity_bar = ColorRect.new()
	_rarity_bar.position = Vector2(0, 0)
	_rarity_bar.size = Vector2(4, CARD_H)
	_rarity_bar.color = Color(0.4, 0.4, 0.4)
	_rarity_bar.mouse_filter = MOUSE_FILTER_IGNORE
	_visual.add_child(_rarity_bar)

	_produces_label = RichTextLabel.new()
	_produces_label.position = Vector2(8, 5)
	_produces_label.size = Vector2(CARD_W - 16, 18)
	_produces_label.bbcode_enabled = true
	_produces_label.scroll_active = false
	_produces_label.mouse_filter = MOUSE_FILTER_IGNORE
	_produces_label.add_theme_font_size_override("normal_font_size", 13)
	_visual.add_child(_produces_label)

	_art_rect = ColorRect.new()
	_art_rect.position = Vector2(6, 26)
	_art_rect.size = Vector2(CARD_W - 12, 62)
	_art_rect.color = Color(0.24, 0.24, 0.30)
	_art_rect.mouse_filter = MOUSE_FILTER_IGNORE
	_visual.add_child(_art_rect)

	var icon := TextureRect.new()
	icon.position = Vector2(6 + (CARD_W - 12 - 40) / 2.0, 26 + 11)
	icon.size = Vector2(40, 40)
	icon.stretch_mode = TextureRect.STRETCH_SCALE
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon.texture = preload("res://icon.svg")
	icon.mouse_filter = MOUSE_FILTER_IGNORE
	_visual.add_child(icon)

	_name_label = Label.new()
	_name_label.position = Vector2(8, 92)
	_name_label.size = Vector2(CARD_W - 12, 20)
	_name_label.add_theme_font_size_override("font_size", 13)
	var name_font: Font = load("res://fonts/georgia.ttf")
	if not name_font:
		var sys := SystemFont.new()
		sys.font_names = ["Georgia", "Times New Roman", "serif"]
		sys.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_ONE_QUARTER
		sys.hinting = TextServer.HINTING_LIGHT
		sys.oversampling = 2.0
		name_font = sys
	_name_label.add_theme_font_override("font", name_font)
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_name_label.clip_text = true
	_name_label.mouse_filter = MOUSE_FILTER_IGNORE
	_visual.add_child(_name_label)

	_desc_label = Label.new()
	_desc_label.position = Vector2(8, 114)
	_desc_label.size = Vector2(CARD_W - 12, 42)
	_desc_label.add_theme_font_size_override("font_size", 11)
	_desc_label.modulate = Color(0.8, 0.8, 0.85)
	_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_desc_label.mouse_filter = MOUSE_FILTER_IGNORE
	_visual.add_child(_desc_label)

	# Button stays on _visual but is STOP so it can still receive clicks
	_play_btn = Button.new()
	_play_btn.position = Vector2(6, CARD_H - 26)
	_play_btn.size = Vector2(CARD_W - 12, 20)
	_play_btn.add_theme_font_size_override("font_size", 12)
	_play_btn.pressed.connect(_on_play_pressed)
	_visual.add_child(_play_btn)

func setup(card: CardData) -> void:
	card_data = card
	_name_label.text = card.card_name
	_desc_label.text = card.description

	match card.rarity:
		"common":   _rarity_bar.color = Color(0.5, 0.5, 0.55)
		"uncommon": _rarity_bar.color = Color(0.3, 0.7, 0.35)
		"cursed":   _rarity_bar.color = Color(0.75, 0.15, 0.25)

	_refresh_produces(_produces_label, card.produces)

func set_playable(enabled: bool) -> void:
	_play_btn.disabled = not enabled

func set_action_label(text: String) -> void:
	_play_btn.text = text

func _refresh_produces(label: RichTextLabel, res_dict: Dictionary) -> void:
	label.clear()
	var first := true
	for resource in res_dict:
		if not first:
			label.push_color(Color(0.5, 0.5, 0.5))
			label.append_text(" · ")
			label.pop()
		var col := _resource_color(resource)
		label.push_color(col)
		label.append_text(_resource_abbrev(resource) + str(int(res_dict[resource])))
		label.pop()
		first = false

func _resource_abbrev(resource: String) -> String:
	match resource:
		"gold":        return "◈ "
		"arcana":      return "✦ "
		"insight":     return "◆ "
		"faith":       return "▲ "
		"electricity": return "⬡ "
	return "■ "

func _resource_color(resource: String) -> Color:
	match resource:
		"gold":        return Color(1.0, 0.82, 0.1)
		"arcana":      return Color(0.6, 0.2, 0.9)
		"insight":     return Color(0.1, 0.8, 0.9)
		"faith":       return Color(0.95, 0.93, 0.8)
		"electricity": return Color(0.2, 0.55, 1.0)
	return Color(0.6, 0.6, 0.6)

func _on_hover_start() -> void:
	z_index = 1
	var t := create_tween()
	t.tween_property(_visual, "scale", Vector2(1.12, 1.12), 0.1)

func _on_hover_end() -> void:
	z_index = 0
	var t := create_tween()
	t.tween_property(_visual, "scale", Vector2(1.0, 1.0), 0.1)

func _on_play_pressed() -> void:
	if card_data != null:
		card_played.emit(card_data)
