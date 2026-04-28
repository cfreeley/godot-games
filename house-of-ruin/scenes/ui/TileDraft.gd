extends Control

const OPTION_W := 140
const OPTION_H := 220
const OPTION_GAP := 20

var _bg: ColorRect
var _title: Label
var _skip_btn: Button
var _option_views: Array = []
var _CardViewScene := preload("res://scenes/cards/CardView.tscn")

func _ready() -> void:
  _build_visual()
  GameManager.phase_changed.connect(_on_phase_changed)

func _build_visual() -> void:
  _bg = ColorRect.new()
  _bg.color = Color(0.0, 0.0, 0.0, 0.75)
  _bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
  add_child(_bg)

  _title = Label.new()
  _title.text = "Choose a Room to Add to Your House"
  _title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
  _title.add_theme_font_size_override("font_size", 18)
  _title.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
  _title.offset_top = 40
  _title.offset_bottom = 70
  add_child(_title)

  _skip_btn = Button.new()
  _skip_btn.text = "Skip (Begin Living Phase)"
  _skip_btn.add_theme_font_size_override("font_size", 13)
  _skip_btn.pressed.connect(_on_skip)
  add_child(_skip_btn)

  visible = false

func _show_draft() -> void:
  for v in _option_views:
    v.queue_free()
  _option_views.clear()

  var options := CardLibrary.get_random_draft(3)
  var total_w := options.size() * (OPTION_W + OPTION_GAP) - OPTION_GAP
  var vp := get_viewport_rect().size
  var start_x := (vp.x - total_w) / 2.0
  var card_y := (vp.y - OPTION_H) / 2.0 - 20.0

  for i in range(options.size()):
    var card: CardData = options[i]
    var view: Control = _CardViewScene.instantiate()
    add_child(view)
    view.setup(card)
    view.position = Vector2(start_x + i * (OPTION_W + OPTION_GAP), card_y)
    view.custom_minimum_size = Vector2(OPTION_W, OPTION_H)
    view.card_played.connect(_on_option_chosen)

    # Show cost in the button
    var cost_str := _cost_label(card)
    view.set_action_label("Build  " + cost_str if cost_str != "" else "Build")

    # Gray out if can't afford
    view.set_playable(GameManager.can_afford(card))
    _option_views.append(view)

  _skip_btn.position = Vector2((vp.x - 200.0) / 2.0, card_y + OPTION_H + 20.0)
  _skip_btn.size = Vector2(200, 36)
  visible = true

func _cost_label(card: CardData) -> String:
  if card.cost.is_empty():
    return "(free)"
  var parts: Array[String] = []
  for resource in card.cost:
    parts.append("%d %s" % [card.cost[resource], resource])
  return "(%s)" % ", ".join(parts)

func _on_option_chosen(card: CardData) -> void:
  if not GameManager.can_afford(card):
    push_warning("TileDraft: can't afford " + card.card_name)
    return
  visible = false
  GameManager.select_draft_tile(card)
  # HouseBoard now shows build slots; player picks location
  # Living phase starts after placement (from HouseBoard)

func _on_skip() -> void:
  visible = false
  GameManager.enter_living_phase()

func _on_phase_changed(phase: GameManager.Phase) -> void:
  if phase == GameManager.Phase.BUILD:
    _show_draft()
  else:
    visible = false
