extends Control

var _end_turn_btn: Button
var _end_phase_btn: Button
var _deck_label: Label

func _ready() -> void:
	_build_visual()
	GameManager.phase_changed.connect(_on_phase_changed)
	DeckManager.deck_changed.connect(_refresh_deck_label)
	DeckManager.hand_updated.connect(_refresh_deck_label)

func _build_visual() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.1, 0.1, 0.13)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 8)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(vbox)

	_end_turn_btn = Button.new()
	_end_turn_btn.text = "End Turn"
	_end_turn_btn.add_theme_font_size_override("font_size", 14)
	_end_turn_btn.custom_minimum_size = Vector2(140, 40)
	_end_turn_btn.pressed.connect(_on_end_turn)
	_end_turn_btn.disabled = true
	vbox.add_child(_end_turn_btn)

	_end_phase_btn = Button.new()
	_end_phase_btn.text = "End Phase"
	_end_phase_btn.add_theme_font_size_override("font_size", 12)
	_end_phase_btn.custom_minimum_size = Vector2(140, 34)
	_end_phase_btn.pressed.connect(_on_end_phase)
	_end_phase_btn.disabled = true
	vbox.add_child(_end_phase_btn)

	_deck_label = Label.new()
	_deck_label.text = "Deck: 0"
	_deck_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_deck_label.add_theme_font_size_override("font_size", 11)
	_deck_label.modulate = Color(0.6, 0.6, 0.7)
	vbox.add_child(_deck_label)

func _on_end_turn() -> void:
	GameManager.end_turn()

func _on_end_phase() -> void:
	GameManager.enter_build_phase()

func _on_phase_changed(phase: GameManager.Phase) -> void:
	var in_living := phase == GameManager.Phase.LIVING
	_end_turn_btn.disabled = not in_living
	_end_phase_btn.disabled = not in_living

func _refresh_deck_label() -> void:
	_deck_label.text = "Deck: %d  Hand: %d  Discard: %d" % [
		DeckManager.deck.size(),
		DeckManager.hand.size(),
		DeckManager.discard.size()
	]
