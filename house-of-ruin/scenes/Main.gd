extends Node

func _ready() -> void:
  _setup_font_quality()
  GameManager.run_ended.connect(_on_run_ended)
  GameManager.start_run()

func _setup_font_quality() -> void:
  # Try to load the MSDF-imported Segoe UI font (res://fonts/segoeui.ttf).
  # Godot imports it with multichannel_signed_distance_field=true on first
  # project open, giving resolution-independent text at any Camera2D zoom.
  # Falls back to an oversampled SystemFont if not yet imported.
  var ui_font: Font = load("res://fonts/segoeui.ttf")
  if not ui_font:
    var sys := SystemFont.new()
    sys.font_names = ["Segoe UI", "Ubuntu", "Helvetica Neue", "Arial", "sans-serif"]
    sys.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_ONE_QUARTER
    sys.hinting = TextServer.HINTING_LIGHT
    sys.oversampling = 2.0
    ui_font = sys
  ThemeDB.fallback_font = ui_font
  ThemeDB.fallback_font_size = 13

func _on_run_ended(won: bool) -> void:
  if won:
    print("Run won!")
  else:
    print("Run lost — restarting...")
    await get_tree().create_timer(2.0).timeout
    GameManager.start_run()
