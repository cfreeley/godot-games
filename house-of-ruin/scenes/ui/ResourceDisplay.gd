extends Control

var _labels: Dictionary = {}
var _hp_label: Label
var _phase_label: Label

func _ready() -> void:
  _build_visual()
  GameManager.resources_changed.connect(_refresh)
  GameManager.phase_changed.connect(_on_phase_changed)

func _build_visual() -> void:
  var bg := ColorRect.new()
  bg.color = Color(0.08, 0.08, 0.1)
  bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
  add_child(bg)

  var hbox := HBoxContainer.new()
  hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
  hbox.add_theme_constant_override("separation", 32)
  hbox.alignment = BoxContainer.ALIGNMENT_CENTER
  add_child(hbox)

  for key in ["gold", "arcana", "insight"]:
    var lbl := Label.new()
    lbl.add_theme_font_size_override("font_size", 14)
    hbox.add_child(lbl)
    _labels[key] = lbl

  _hp_label = Label.new()
  _hp_label.add_theme_font_size_override("font_size", 14)
  hbox.add_child(_hp_label)

  _phase_label = Label.new()
  _phase_label.add_theme_font_size_override("font_size", 14)
  _phase_label.modulate = Color(0.7, 0.9, 0.7)
  _phase_label.text = "[ BUILD PHASE ]"
  hbox.add_child(_phase_label)

  _refresh()

func _refresh() -> void:
  var r := GameManager.resources
  _labels["gold"].text = "Gold: %d" % r.get("gold", 0)
  _labels["arcana"].text = "Arcana: %d" % r.get("arcana", 0)
  _labels["insight"].text = "Insight: %d" % r.get("insight", 0)
  _hp_label.text = "HP: %d/%d" % [GameManager.hp, GameManager.MAX_HP]

func _on_phase_changed(phase: GameManager.Phase) -> void:
  _phase_label.text = "[ BUILD PHASE ]" if phase == GameManager.Phase.BUILD else "[ LIVING PHASE ]"
