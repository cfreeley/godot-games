extends Node2D

var DIRECTIONS = [Vector2(2,0), Vector2(1,1), Vector2(-1, 1), Vector2(-2, 0), Vector2(-1, -1), Vector2(1, -1)]

var TileColors = {
  "Plain": [ Color.LAWN_GREEN, Color.GREEN, Color.LAWN_GREEN, Color.LAWN_GREEN, Color.LAWN_GREEN, Color.LAWN_GREEN, Color.LAWN_GREEN],
  "Forest": [ Color.DARK_GREEN, Color.YELLOW_GREEN, Color.GREEN, Color.DARK_GREEN, Color.DARK_GREEN, Color.DARK_GREEN, Color.DARK_GREEN ],
  "Mountain": [ Color.SADDLE_BROWN, Color.SANDY_BROWN, Color.YELLOW, Color.SADDLE_BROWN, Color.SADDLE_BROWN, Color.SANDY_BROWN, Color.SADDLE_BROWN ],
  "River": [ Color.BLUE, Color.DARK_BLUE, Color.STEEL_BLUE, Color.BLUE, Color.BLUE, Color.DARK_BLUE, Color.STEEL_BLUE ],
  "Town": [ Color.SILVER ]
}

class Tile:
  var type = "Plain"
  var tribe = null
  var coord
  func _init(in_coord):
    coord = in_coord

func get_hex_points(hex: Tile):
  var hex_w = sqrt(3)
  var hex_h = 2
  return [
    Vector2(0, -hex_h / 2), # top
    Vector2(hex_w / 2, -hex_h * .25), # top right
    Vector2(hex_w / 2, hex_h * .25), # bottom right
    Vector2(0, hex_h / 2), # bottom
    Vector2(-hex_w / 2, hex_h * .25), # bottom left
    Vector2(-hex_w / 2, -hex_h * .25), # top left
    Vector2(0, -hex_h / 2), # top
  ]

func draw_tile(hex: Tile, pos: Vector2, size: float):
  var points = get_hex_points(hex).map(func(pt): return (pt * size) + pos)
  TileColors[hex.type].shuffle()
  draw_polygon(PackedVector2Array(points), PackedColorArray(TileColors[hex.type]))
  if hex.tribe != null:
    var col: Color = hex.tribe
    col.a = .4
    draw_polygon(PackedVector2Array(points), PackedColorArray([col]))
  
var TileGrid = {}
var zoom = 0
func _ready():
  build_grid()
  get_neighbors(TileGrid[Vector2(4,4)])
  
func get_diversity():
  return (TileGrid.values().reduce(func(acc, h):
    return acc + (1.0 if h.type != "Plain" else 0.0), 0.0)) / TileGrid.size()
  
func build_grid():
  var num_rows = 100
  var num_cols = 100
  for row in num_rows:
    for col in num_cols:
      var offset = 0 if row % 2 == 0 else 1
      var coord = Vector2((col * 2) + offset, row)
      var tile = Tile.new(coord)
      TileGrid[coord] = tile
  while get_diversity() < .35:
    grow_river(get_rand_tile())
    grow_forest(get_rand_tile())
  while get_diversity() < .4:
    grow_mountain(get_rand_tile())
  var towns_to_build = 25
  while towns_to_build > 0:
    towns_to_build -= 1 if build_town(get_rand_tile()) else 0
      
func get_neighbors(hex: Tile):
  var neighbors = []
  for coord in DIRECTIONS:
    var neighbor_coord = coord + hex.coord
    if TileGrid.has(neighbor_coord):
      neighbors.push_back(TileGrid[neighbor_coord])
  return neighbors
  
func get_rand_tile():
  var coords = TileGrid.keys()
  coords.shuffle()
  return TileGrid[coords[0]]
  
func grow_river(hex: Tile, odds= 1, dirs= null):
  if odds > randf() and hex.type != "River":
    hex.type = "River"
    if dirs == null:
      var dir = randi() % 6
      dirs = [DIRECTIONS[dir], DIRECTIONS[(dir+1) % 6], DIRECTIONS[(dir+2)%6]]
    var next = hex.coord + dirs[randi() % dirs.size()]
    if TileGrid.has(next):
      grow_river(TileGrid[next], odds * .99, dirs)
      
func grow_mountain(hex: Tile, length=null, dirs= null):
  hex.type = "Mountain"
  if dirs == null:
    var dir = randi() % 6
    dirs = [DIRECTIONS[dir], DIRECTIONS[(dir+1) % 6], DIRECTIONS[(dir+2)%6]]
    length = (randi() % 16) + 6
  var next_dir = randi() % dirs.size()
  var next = hex.coord + dirs[next_dir]
  var n2 = hex.coord + dirs[(next_dir + 1) % dirs.size()]
  var n3 = hex.coord + dirs[(next_dir - 1) % dirs.size()]
  if TileGrid.has(n2) and TileGrid.has(n3):
    TileGrid[n2].type = "Mountain"
    TileGrid[n3].type = "Mountain"
  if TileGrid.has(next) and length > 0:
    grow_mountain(TileGrid[next], length-1, dirs)
      
func grow_forest(hex: Tile, odds = .99):
  if odds > randf() and hex.type != "Forest":
    hex.type = "Forest"
    for h in get_neighbors(hex):
      grow_forest(h, odds * .8)
      
func build_town(hex: Tile):
  var num_resources = {}
  for h in get_neighbors(hex):
    if !num_resources.has(h.type):
      num_resources[h.type] = 0
    num_resources[h.type] += 1
  if num_resources.size() >= 2 && (num_resources.size() / 4.0) > randf():
    hex.type = "Town"
    return true
  return false

var Tribe = {}
func add_tribe(hex: Tile):
  if Tribe.is_empty():
    Tribe[hex.coord] = hex
    hex.tribe = Color.MAGENTA
  else:
    for n in get_neighbors(hex):
      if n.tribe == Color.MAGENTA:
        Tribe[hex.coord] = hex
        hex.tribe = Color.MAGENTA

func get_size(): return 16 * pow(2.0, (zoom / 4.0))
func get_hor_spacing(): return (get_size() * sqrt(3))
func get_ver_spacing(): return (get_size() * (3.0/2))
var hor_offset = 0
var ver_offset = 0

func coord_to_pos(c: Vector2):
  return Vector2(((c.x / 2) * get_hor_spacing()) + hor_offset, (c.y * get_ver_spacing()) + ver_offset)

func draw_tribe():
  var pt_dict = {}
  for h in Tribe:
    var ml_pts: Array = get_hex_points(Tribe[h]).reduce(func (acc, pt): # turn hex pts into multiline
      acc.append_array([pt, pt])
      return acc, [])
    ml_pts.pop_back(); ml_pts.pop_front(); # only middle duped
    var test = {
      Vector2(1,1): 5,
      [1,2]: 4
    }
    pt_dict = ml_pts.reduce(func (acc: Dictionary, coord: Vector2):
      var pt = (coord*get_size()) + coord_to_pos(Tribe[h].coord)
      if acc.is_empty() or !acc.has("hold"):
        acc.hold = pt.round()
        return acc
      var pair = [acc.hold, pt.round()]
      pair.sort()
      acc.erase("hold")
      acc[pair] = acc.has(pair)
      return acc, pt_dict.duplicate()) # [ [a, b] [a, b] ]
  var flat_pts = pt_dict.keys().filter(func(key): return !pt_dict[key]).reduce(func(acc, pair):
    acc.append_array(pair)
    return acc, [])
  draw_multiline(PackedVector2Array(flat_pts), Color.MAGENTA, 4)

func _draw():
  for coord in TileGrid:
    var tile = TileGrid[coord]
    draw_tile(tile, coord_to_pos(coord), get_size())
  draw_tribe()
    
func _input(event):
  if event is InputEventMouseButton:
    if event.button_index == 4:
        zoom += 1
        queue_redraw()
    elif event.button_index == 5:
        zoom -= 1
        queue_redraw()
    elif event.button_index == 1:
      var pos = event.position
      var orig_grid_x = ((pos.x - hor_offset) / get_hor_spacing()) * 2
      var grid_x = round(orig_grid_x)
      var grid_y = round((pos.y - ver_offset) / get_ver_spacing())
      if (int(grid_x) + int(grid_y)) % 2 != 0:
        grid_x += 1 if grid_x < orig_grid_x else -1 # round to nearest hex
      var grid_pos = Vector2(grid_x, grid_y)
      if TileGrid.has(grid_pos):
        add_tribe(TileGrid[grid_pos])
        queue_redraw()
