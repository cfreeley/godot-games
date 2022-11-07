extends Node

var DEFAULT_WIDTH = 15
var DEFAULT_HEIGHT = 15
var grid = []

func _ready():
	make_grid()

func make_grid(w = DEFAULT_WIDTH, h = DEFAULT_HEIGHT):
	grid = []
	for _n in range(0, w):
		var col = []
		for _m in range(0, h):
			col.append(null)
		grid.append(col)

func register(tile, pos):
	grid[pos.x][pos.y] = tile
	
func clear(pos):
	grid[pos.x][pos.y] = null

func check_pos(pos):
	 return (pos.x < grid.size() && pos.x >= 0 
		&& pos.y < grid[0].size() && pos.y >= 0 
		&& grid[pos.x][pos.y] == null)

func get_cell(pos):
	return grid[pos.x][pos.y]

func print_grid():
	print ("===")
	for row in grid[0].size():
		var row_s = ""
		for col in grid.size():
			var cell = grid[col][row]
			row_s = str(row_s, ", " if col != 0 else "", str(cell).substr(0,1) if cell else "-")
		print(row_s)
