extends Node2D

var CurrentLoc : Vector2
var CurrentRoom : Node2D

var LEFT = Vector2(-1, 0)
var RIGHT = Vector2(1, 0)
var UP = Vector2(0, -1)
var DOWN = Vector2(0, 1)

var Start = Vector2(2, 4)
var Entrance = Start + UP
var SW_Corner = Entrance + LEFT
var SE_Corner = Entrance + RIGHT
var Center = Entrance + UP
var Back = Center + UP
var NW_Corner = Back + LEFT
var NE_Corner = Back + RIGHT
var Map := {
  Start: preload("res://rooms/PlayerCell.tscn").instantiate(),
  Entrance: preload("res://rooms/EntranceWay.tscn").instantiate(),
  SE_Corner: preload("res://rooms/EmptyHall.tscn").instantiate(),
  (SE_Corner + RIGHT): preload("res://rooms/EmptyHall.tscn").instantiate(),
  (SE_Corner + DOWN): preload("res://rooms/EmptyHall.tscn").instantiate(),
  SW_Corner: preload("res://rooms/EmptyHall.tscn").instantiate(),
  (SW_Corner + DOWN): preload("res://rooms/EmptyHall.tscn").instantiate(),
  (SW_Corner + LEFT): preload("res://rooms/EmptyHall.tscn").instantiate(),
  Center: preload("res://rooms/EmptyHall.tscn").instantiate(),
  (Center + LEFT): preload("res://rooms/EmptyHall.tscn").instantiate(),
  (Center + RIGHT): preload("res://rooms/EmptyHall.tscn").instantiate(),
  Back: preload("res://rooms/EmptyHall.tscn").instantiate(),
  (Back + UP): preload("res://rooms/EmptyHall.tscn").instantiate(),
  NE_Corner: preload("res://rooms/EmptyHall.tscn").instantiate(),
  (NE_Corner + UP): preload("res://rooms/EmptyHall.tscn").instantiate(),
  (NE_Corner + RIGHT): preload("res://rooms/EmptyHall.tscn").instantiate(),
  NW_Corner: preload("res://rooms/EmptyHall.tscn").instantiate(),
  (NW_Corner + UP): preload("res://rooms/EmptyHall.tscn").instantiate(),
  (NW_Corner + UP + LEFT): preload("res://rooms/EmptyHall.tscn").instantiate(),
}

var Keys := ['security']
var Doors := {
  [Start, Entrance]: null,
  [Entrance, Center]: 'guard',
  [Entrance, SW_Corner]: null,
  [SW_Corner, SW_Corner + DOWN]: null,
  [SW_Corner, SW_Corner + LEFT]: null,
  [Entrance, SE_Corner]: null,
  [SW_Corner, Center + LEFT]: null,
  [SE_Corner, Center + RIGHT]: null,
  [SE_Corner, SE_Corner + RIGHT]: null,
  [SE_Corner, SE_Corner + DOWN]: null,
  [NW_Corner, Center + LEFT]: null,
  [NE_Corner, Center + RIGHT]: null,
  [Back, Back + UP]: null,
  [NE_Corner, Back]: null,
  [NE_Corner, NE_Corner + UP]: null,
  [NE_Corner, NE_Corner + RIGHT]: null,
  [NW_Corner, Back]: null,
  [NW_Corner, NW_Corner + UP]: 'security',
  [NW_Corner + UP, NW_Corner + UP + LEFT]: null,
}

var SeenRooms := {}

func _ready():
  $CanvasLayer/MainMenu.show()

func enter_room(loc):
  if CurrentRoom != null:
    remove_child(CurrentRoom)  
  CurrentRoom = Map[loc]
  assert(CurrentRoom != null, "out of bounds at: %s" % loc)
  add_child(CurrentRoom)
  CurrentLoc = loc
  SeenRooms[loc] = true
  CurrentRoom.enter()

var input_to_dir = {
  "ui_up": UP,
  "ui_down": DOWN,
  "ui_left": LEFT,
  "ui_right": RIGHT,
}

func _unhandled_input(event):
  queue_redraw()
  if event.is_action_pressed("investigate"):
    CurrentRoom.investigate()
  else:
    for action in input_to_dir.keys():
      if event.is_action_pressed(action):
        var dir = input_to_dir[action]
        var new_loc = CurrentLoc + dir
        if Map.has(new_loc):
          enter_room(new_loc)
        else:
          print(Map, Map.get(new_loc), new_loc)


func _on_start_button_pressed():
  enter_room(Start)
  $CanvasLayer/MainMenu.hide()
  queue_redraw()

var canvas_width = 360
var canvas_height = 360
var canvas_pos = Vector2(720 / 2 - (canvas_width / 2), 720 / 2 - (canvas_height / 2))
func _draw():
  var grid_w = 5
  var grid_h = 5
  var buffer = 8
  var w = (canvas_width / grid_w) - buffer
  var h = (canvas_height / grid_h) - buffer
  var getPos = func getPos(loc): return Vector2((w+buffer)*loc.x + (buffer/2), (h+buffer)*loc.y + (buffer/2)) + canvas_pos
  for loc in Map.keys():
    var coord = Vector2(loc.x, loc.y)
    var pos = getPos.call(loc)
    var size = Vector2(w, h)
    var fillCol = Color.BLACK
    if SeenRooms.has(coord):
      fillCol = Color.YELLOW if coord == CurrentLoc else Color.BLUE
    draw_rect(Rect2(pos, size), fillCol, true, 2.0)
    draw_rect(Rect2(pos, size), Color.DARK_BLUE, false, 2.0)
      
        
  for door in Doors.keys():
    var door_size = 16
    var base_pos = getPos.call(door[0]) - Vector2(door_size / 2, door_size / 2)
    var dir = door[1] - door[0]
    var door_pos : Vector2
    if (dir == DOWN):
      door_pos = base_pos + Vector2(w/2, h + (buffer/2))
    elif (dir == UP):
      door_pos = base_pos + Vector2(w/2, -(buffer/2))
    elif (dir == LEFT):
      door_pos = base_pos + Vector2(-(buffer/2), h/2)
    else:
      door_pos = base_pos + Vector2(w + (buffer/2), h/2)
    var col = Color.BLACK
    if Doors[door] != null and (SeenRooms.has(door[0]) or SeenRooms.has(door[1])):
      col = Color.RED if !Keys.has(Doors[door]) else Color.WEB_GREEN
    draw_rect(Rect2(door_pos, Vector2(door_size, door_size)), col, true)
  
