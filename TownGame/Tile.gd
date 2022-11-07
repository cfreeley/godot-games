extends Node2D

onready var GRID = $"/root/Grid"

enum DIRECTION { UP = 0, RIGHT = 1, DOWN = 2, LEFT = 3, STAY = -1 }
var DIRECTIONS = { 
	DIRECTION.UP: Vector2(0,-1),
	DIRECTION.RIGHT: Vector2(1,0),
	DIRECTION.DOWN: Vector2(0,1),
	DIRECTION.LEFT: Vector2(-1,0),
	DIRECTION.STAY: Vector2(0,0)
}

var MOVE_SPEED = 128
var CELL_LEN = 32
var POS_OFFSET = Vector2(0,0) # Vector2(CELL_LEN / 2, CELL_LEN / 2)
onready var destination = position
onready var last_position = position
var direction = DIRECTION.DOWN setget set_direction

func set_direction(new_dir):
	direction = new_dir
	if ($Sprite and $Sprite.animation):
		match new_dir:
			DIRECTION.DOWN:
				$Sprite.animation = "down"
			DIRECTION.UP:
				$Sprite.animation = "up"
			DIRECTION.RIGHT:
				$Sprite.animation = "right"
				$Sprite.flip_h = false
			DIRECTION.LEFT:
				$Sprite.animation = "right"
				$Sprite.flip_h = true

func to_pos(cell):
	return (cell * CELL_LEN) + POS_OFFSET

func to_cell(pos = position):
	return (pos - POS_OFFSET) / CELL_LEN

func move_to_dest(delta):
	if ($Sprite):
		$Sprite.playing = destination != position

	if (destination != position):
		position.x = move_toward(position.x, destination.x, MOVE_SPEED * delta)
		position.y = move_toward(position.y, destination.y, MOVE_SPEED * delta)
		if (destination == position):
			GRID.clear(to_cell(last_position))
			
func next_cell_from_dir(dir = direction):
	return (DIRECTIONS[dir] * CELL_LEN) + position
		
func move_from_dir(dir):
	if (dir == DIRECTION.STAY):
		return true

	var attempted_dest = next_cell_from_dir(dir)
	set_direction(dir)
	if (GRID.check_pos(to_cell(attempted_dest))):
		GRID.register(self, to_cell(attempted_dest))
		last_position = position
		destination = attempted_dest
	else:
		return false
	return true

func _ready():
	GRID.register(self, to_cell())

func _process(delta):
	move_to_dest(delta)
