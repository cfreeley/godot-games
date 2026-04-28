extends Control

const CARD_SPACING := 8
var _CardViewScene := preload("res://scenes/cards/CardView.tscn")
var _card_views: Array = []
var _bg: ColorRect
var _label: Label

func _ready() -> void:
	_build_visual()
	DeckManager.hand_updated.connect(_refresh_hand)
	GameManager.phase_changed.connect(_on_phase_changed)

func _build_visual() -> void:
	_bg = ColorRect.new()
	_bg.color = Color(0.1, 0.1, 0.13)
	_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_bg)

	_label = Label.new()
	_label.text = "Hand"
	_label.position = Vector2(8, 4)
	_label.add_theme_font_size_override("font_size", 11)
	_label.modulate = Color(0.5, 0.5, 0.6)
	add_child(_label)

func _refresh_hand() -> void:
	for v in _card_views:
		v.queue_free()
	_card_views.clear()

	var x := 8
	for card in DeckManager.hand:
		var view: Control = _CardViewScene.instantiate()
		add_child(view)
		view.setup(card)
		view.position = Vector2(x, 16)
		view.card_played.connect(_on_card_played)
		_card_views.append(view)
		x += 120 + CARD_SPACING

func _on_card_played(card: CardData) -> void:
	GameManager.play_card(card)

func _on_phase_changed(phase: GameManager.Phase) -> void:
	# Cards only playable during LIVING phase
	var in_living := phase == GameManager.Phase.LIVING
	for v in _card_views:
		v.set_playable(in_living)
