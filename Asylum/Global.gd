extends Node
signal room_enter()
signal room_investigate()
signal room_move(dir : String)

var PlayerStats := {
  'STR': 0,
  'AGI': 0,
  'ARC': 0,
  'HP': 4
}

var CurrentLoc : Vector2

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

func get_door(l1, l2):
  if Doors.has([l1, l2]):
    return [l1, l2];
  elif Doors.has([l2, l1]):
    return [l2, l1]
  return false;

var SeenRooms := {}
