extends Control

const TILE_W := 114
const TILE_H := 94

var card_data: CardData = null
var has_threat: bool = false

var _bg: ColorRect
var _rarity_bar: ColorRect
var _art_rect: ColorRect
var _icon: TextureRect
var _produces_label: RichTextLabel
var _name_label: Label
var _threat_box: ColorRect

func _ready() -> void:
  custom_minimum_size = Vector2(TILE_W, TILE_H)
  size = Vector2(TILE_W, TILE_H)
  mouse_filter = MOUSE_FILTER_IGNORE  # HouseBoard._unhandled_input handles clicks
  _build_visual()

func _build_visual() -> void:
  _bg = ColorRect.new()
  _bg.position = Vector2.ZERO
  _bg.size = Vector2(TILE_W, TILE_H)
  _bg.color = Color(0.15, 0.15, 0.18)
  add_child(_bg)

  # Rarity bar along left edge
  _rarity_bar = ColorRect.new()
  _rarity_bar.position = Vector2(0, 0)
  _rarity_bar.size = Vector2(4, TILE_H)
  _rarity_bar.color = Color(0.4, 0.4, 0.4)
  add_child(_rarity_bar)

  # Art placeholder — sits just below produces row
  _art_rect = ColorRect.new()
  _art_rect.position = Vector2(6, 4)
  _art_rect.size = Vector2(TILE_W - 12, 44)
  _art_rect.color = Color(0.22, 0.22, 0.28)
  add_child(_art_rect)

  # Godot icon placeholder — centered in art rect
  _icon = TextureRect.new()
  _icon.position = Vector2(6 + (TILE_W - 12 - 32) / 2.0, 4 + 6)
  _icon.size = Vector2(32, 32)
  _icon.stretch_mode = TextureRect.STRETCH_SCALE
  _icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
  _icon.texture = preload("res://icon.svg")
  add_child(_icon)

  # Single RichTextLabel for produces — avoids child-node rendering issues
  _produces_label = RichTextLabel.new()
  _produces_label.position = Vector2(6, 50)
  _produces_label.size = Vector2(TILE_W - 12, 20)
  _produces_label.bbcode_enabled = true
  _produces_label.scroll_active = false
  _produces_label.mouse_filter = MOUSE_FILTER_IGNORE
  _produces_label.add_theme_font_size_override("normal_font_size", 13)
  add_child(_produces_label)

  # Room name — Georgia for the gothic serif feel
  _name_label = Label.new()
  _name_label.position = Vector2(6, 72)
  _name_label.size = Vector2(TILE_W - 12, 20)
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
  _name_label.text = "Empty"
  _name_label.clip_text = true
  add_child(_name_label)

  # Threat indicator — top-right corner
  _threat_box = ColorRect.new()
  _threat_box.position = Vector2(TILE_W - 18, 2)
  _threat_box.size = Vector2(16, 16)
  _threat_box.color = Color(0.9, 0.15, 0.15)
  _threat_box.visible = false
  add_child(_threat_box)

  var t_lbl := Label.new()
  t_lbl.text = "!"
  t_lbl.position = Vector2(4, -2)
  t_lbl.add_theme_font_size_override("font_size", 14)
  _threat_box.add_child(t_lbl)

func set_card(card: CardData) -> void:
  card_data = card
  _refresh()

func set_threat(active: bool) -> void:
  has_threat = active
  _threat_box.visible = active

func _refresh() -> void:
  if card_data == null:
    _bg.color = Color(0.12, 0.12, 0.15)
    _name_label.text = ""
    _rarity_bar.color = Color(0.25, 0.25, 0.25)
    return

  _name_label.text = card_data.card_name

  match card_data.rarity:
    "common":   _bg.color = Color(0.18, 0.20, 0.25); _rarity_bar.color = Color(0.5, 0.5, 0.55)
    "uncommon": _bg.color = Color(0.16, 0.23, 0.18); _rarity_bar.color = Color(0.3, 0.7, 0.35)
    "cursed":   _bg.color = Color(0.25, 0.13, 0.17); _rarity_bar.color = Color(0.75, 0.15, 0.25)

  # Rebuild produces label
  _refresh_produces(card_data.produces)

func _refresh_produces(res_dict: Dictionary) -> void:
  _produces_label.clear()
  var first := true
  for resource in res_dict:
    if not first:
      _produces_label.push_color(Color(0.6, 0.6, 0.6))
      _produces_label.append_text(" · ")
      _produces_label.pop()
    var col := _resource_color(resource)
    _produces_label.push_color(col)
    _produces_label.append_text(_resource_abbrev(resource) + str(int(res_dict[resource])))
    _produces_label.pop()
    first = false

func _resource_abbrev(resource: String) -> String:
  # Each entry is a unicode glyph + space that acts as the coloured pip.
  # Noto Sans (Godot's built-in font) supports all of these.
  match resource:
    "gold":        return "◈ "   # U+25C8 white diamond containing black small diamond
    "arcana":      return "✦ "   # U+2726 black four pointed star
    "insight":     return "◆ "   # U+25C6 black diamond
    "faith":       return "▲ "   # U+25B2 black up-pointing triangle
    "electricity": return "⬡ "   # U+2B21 white hexagon (power grid)
  return "■ "   # fallback black square

func _resource_color(resource: String) -> Color:
  match resource:
    "gold":        return Color(1.0, 0.82, 0.1)
    "arcana":      return Color(0.6, 0.2, 0.9)
    "insight":     return Color(0.1, 0.8, 0.9)
    "faith":       return Color(0.95, 0.93, 0.8)
    "electricity": return Color(0.2, 0.55, 1.0)
  return Color(0.6, 0.6, 0.6)

func threat_indicator_world_rect() -> Rect2:
  # Returns the world-space rect of the ! badge so HouseBoard can hit-test it
  var origin: Vector2 = position + Vector2(TILE_W - 18, 2)
  return Rect2(origin, Vector2(16, 16))
