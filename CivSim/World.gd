extends Node2D

var DIRECTIONS = [Vector2(2,0), Vector2(1,1), Vector2(-1, 1), Vector2(-2, 0), Vector2(-1, -1), Vector2(1, -1)]

var TileColors = {
  "Plain": [ Color.LAWN_GREEN, Color.GREEN, Color.LAWN_GREEN, Color.LAWN_GREEN, Color.LAWN_GREEN, Color.LAWN_GREEN, Color.LAWN_GREEN],
  "Forest": [ Color.DARK_GREEN, Color.YELLOW_GREEN, Color.GREEN, Color.DARK_GREEN, Color.DARK_GREEN, Color.DARK_GREEN, Color.DARK_GREEN ],
  "Mountain": [ Color.SADDLE_BROWN, Color.SANDY_BROWN, Color.YELLOW, Color.SADDLE_BROWN, Color.SADDLE_BROWN, Color.SANDY_BROWN, Color.SADDLE_BROWN ],
  "River": [ Color.BLUE, Color.DARK_BLUE, Color.STEEL_BLUE, Color.BLUE, Color.BLUE, Color.DARK_BLUE, Color.STEEL_BLUE ],
}

class Tile:
  var type = "Plain"
  var coord
  func _init(in_coord):
    coord = in_coord

func draw_tile(hex: Tile, pos: Vector2, size: float):
  var hex_w = size * sqrt(3)
  var hex_h = size * 2
  var points = PackedVector2Array([
    pos + Vector2(0, -hex_h / 2), # top
    pos + Vector2(hex_w / 2, -hex_h * .25), # top right
    pos + Vector2(hex_w / 2, hex_h * .25), # bottom right
    pos + Vector2(0, hex_h / 2), # bottom
    pos + Vector2(-hex_w / 2, hex_h * .25), # bottom left
    pos + Vector2(-hex_w / 2, -hex_h * .25), # top left
    pos + Vector2(0, -hex_h / 2), # top
  ])
  TileColors[hex.type].shuffle()
  draw_polygon(points, PackedColorArray(TileColors[hex.type]))
#  draw_polyline(points, Color.BLACK)
  
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

func _draw():
  var size = 16 * pow(2.0, (zoom / 4.0))
  var hor_spacing = (size * sqrt(3))
  var ver_spacing = (size * (3.0/2))
  var hor_offset = 0
  var ver_offset = 0
  for coord in TileGrid:
    var tile = TileGrid[coord]
    draw_tile(tile, Vector2(((coord.x / 2) * hor_spacing) + hor_offset, (coord.y * ver_spacing) + ver_offset), size)
    
func _input(event):
  if event is InputEventMouseButton:
    if event.button_index == 4:
        zoom += 1
        queue_redraw()
    elif event.button_index == 5:
        zoom -= 1
        queue_redraw()

