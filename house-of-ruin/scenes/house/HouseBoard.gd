extends Node2D

const TILE_W := 114
const TILE_H := 94
const GAP := 10
const STEP_X := TILE_W + GAP
const STEP_Y := TILE_H + GAP

# UI panel sizes — used to bias camera so tiles centre in the board area
const PANEL_RIGHT  := 280.0   # GameLog width
const PANEL_TOP    := 52.0    # ResourceDisplay height
const PANEL_BOTTOM := 195.0   # HandArea height

var placed_tiles: Dictionary = {}   # Vector2i -> TileSlot (Control)
var build_slots: Dictionary = {}    # Vector2i -> BuildSlot (Control)
var _pending_card: CardData = null
var _camera: Camera2D

var _TileSlotScene  := preload("res://scenes/house/TileSlot.tscn")
var _BuildSlotScene := preload("res://scenes/house/BuildSlot.tscn")

func _ready() -> void:
  _camera = Camera2D.new()
  _camera.enabled = true
  add_child(_camera)

  GameManager.starting_tile_registered.connect(_on_starting_tile)
  GameManager.tile_draft_selected.connect(_on_draft_selected)
  GameManager.phase_changed.connect(_on_phase_changed)
  GameManager.threat_spawned.connect(_on_threat_spawned)
  GameManager.threat_resolved.connect(_on_threat_resolved)
  GameManager.run_ended.connect(func(_w): _reset())

func _on_starting_tile(card: CardData) -> void:
  _place_tile_at(Vector2i(0, 0), card)
  _fit_camera()

# --- Input: world-space hit testing (works correctly with Camera2D zoom/pan) ---

func _input(event: InputEvent) -> void:
  if not (event is InputEventMouseButton and event.pressed \
      and event.button_index == MOUSE_BUTTON_LEFT):
    return
  # All click handling uses world-space coords to work correctly with Camera2D
  var world_pos: Vector2 = get_viewport().get_canvas_transform().affine_inverse() \
    * event.position

  # Build slot placement
  if _pending_card != null and not build_slots.is_empty():
    for grid_pos: Vector2i in build_slots.keys():
      var rect := Rect2(_grid_to_local(grid_pos), Vector2(TILE_W, TILE_H))
      if rect.has_point(world_pos):
        get_viewport().set_input_as_handled()
        _on_build_slot_selected(grid_pos, _pending_card)
        return

  # Threat badge clicks
  for slot: Control in placed_tiles.values():
    if slot.has_threat and slot.threat_indicator_world_rect().has_point(world_pos):
      get_viewport().set_input_as_handled()
      GameManager.resolve_threat(slot.card_data.id)
      return

# --- Draft placement ---

func _on_draft_selected(card: CardData) -> void:
  _pending_card = card
  _show_build_slots()

func _show_build_slots() -> void:
  _clear_build_slots()
  for pos: Vector2i in _valid_build_positions():
    var slot: Control = _BuildSlotScene.instantiate()
    slot.position = _grid_to_local(pos)
    add_child(slot)
    slot.setup(pos)
    build_slots[pos] = slot
  _fit_camera()

func _on_build_slot_selected(grid_pos: Vector2i, card: CardData) -> void:
  _pending_card = null
  _clear_build_slots()
  _place_tile_at(grid_pos, card)
  if GameManager.confirm_placement(card):
    _fit_camera()
    GameManager.enter_living_phase()
  else:
    # Refund visual if we couldn't afford it
    var slot = placed_tiles.get(grid_pos)
    if slot:
      slot.queue_free()
      placed_tiles.erase(grid_pos)

func _clear_build_slots() -> void:
  for slot: Control in build_slots.values():
    slot.queue_free()
  build_slots.clear()

func _valid_build_positions() -> Array[Vector2i]:
  if placed_tiles.is_empty():
    return [Vector2i(0, 0)]
  var result: Array[Vector2i] = []
  var dirs := [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
  for tile_pos: Vector2i in placed_tiles.keys():
    for dir: Vector2i in dirs:
      var adj: Vector2i = tile_pos + dir
      if not placed_tiles.has(adj) and not result.has(adj):
        result.append(adj)
  return result

# --- Tile placement ---

func _place_tile_at(grid_pos: Vector2i, card: CardData) -> void:
  if placed_tiles.has(grid_pos):
    return
  var slot: Control = _TileSlotScene.instantiate()
  slot.position = _grid_to_local(grid_pos)
  add_child(slot)
  slot.set_card(card)
  placed_tiles[grid_pos] = slot

func _grid_to_local(grid_pos: Vector2i) -> Vector2:
  return Vector2(grid_pos.x * STEP_X, grid_pos.y * STEP_Y)

# --- Camera fitting ---

func _fit_camera() -> void:
  var all_keys: Array[Vector2i] = []
  all_keys.append_array(placed_tiles.keys())
  all_keys.append_array(build_slots.keys())
  if all_keys.is_empty():
    return

  var min_gx := all_keys[0].x; var max_gx := all_keys[0].x
  var min_gy := all_keys[0].y; var max_gy := all_keys[0].y
  for gp: Vector2i in all_keys:
    if gp.x < min_gx: min_gx = gp.x
    if gp.x > max_gx: max_gx = gp.x
    if gp.y < min_gy: min_gy = gp.y
    if gp.y > max_gy: max_gy = gp.y

  var world_min := _grid_to_local(Vector2i(min_gx, min_gy))
  var world_max := _grid_to_local(Vector2i(max_gx, max_gy)) + Vector2(TILE_W, TILE_H)
  var center := (world_min + world_max) * 0.5
  var content_size := (world_max - world_min) + Vector2(STEP_X * 2, STEP_Y * 2)

  var vp_size := get_viewport_rect().size
  var usable := Vector2(maxf(vp_size.x - 320.0, 300.0), maxf(vp_size.y - 260.0, 200.0))
  var zoom_val := clampf(minf(usable.x / content_size.x, usable.y / content_size.y), 0.3, 2.5)

  # Bias camera so content centres in the board area (left of right panels,
  # above hand area). The right panels total 280 px; hand/top bars give a
  # net vertical offset of (PANEL_BOTTOM - PANEL_TOP) / 2.
  var x_bias := (PANEL_RIGHT * 0.5) / zoom_val
  var y_bias := ((PANEL_BOTTOM - PANEL_TOP) * 0.5) / zoom_val
  var cam_target := center + Vector2(x_bias, y_bias)

  var tween := create_tween().set_parallel(true)
  tween.tween_property(_camera, "position", cam_target, 0.45) \
    .set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
  tween.tween_property(_camera, "zoom", Vector2(zoom_val, zoom_val), 0.45) \
    .set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

# --- Threats ---

func _on_threat_spawned(tile_id: String) -> void:
  # Prefer a tile of this type that doesn't already show a threat,
  # so duplicate rooms each get their own independent threat badge.
  for slot: Control in placed_tiles.values():
    if slot.card_data != null and slot.card_data.id == tile_id and not slot.has_threat:
      slot.set_threat(true)
      return
  # Fallback: all matching tiles already threatened — mark the first one anyway.
  for slot: Control in placed_tiles.values():
    if slot.card_data != null and slot.card_data.id == tile_id:
      slot.set_threat(true)
      return

func _on_threat_resolved(tile_id: String) -> void:
  # Clear the threat from the first tile of this type that IS currently threatened.
  for slot: Control in placed_tiles.values():
    if slot.card_data != null and slot.card_data.id == tile_id and slot.has_threat:
      slot.set_threat(false)
      return

func _on_phase_changed(phase: GameManager.Phase) -> void:
  if phase != GameManager.Phase.BUILD:
    _pending_card = null
    _clear_build_slots()

# --- Run reset ---

func _reset() -> void:
  for slot: Control in placed_tiles.values():
    slot.queue_free()
  placed_tiles.clear()
  _pending_card = null
  _clear_build_slots()
