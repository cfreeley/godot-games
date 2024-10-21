extends Node
@warning_ignore("unused_signal")
signal room_enter()
@warning_ignore("unused_signal")
signal room_investigate()
@warning_ignore("unused_signal")
signal room_move(dir : String)
@warning_ignore("unused_signal")
signal choose()
@warning_ignore("unused_signal")
signal choose_combat()
@warning_ignore("unused_signal")
signal enemy_dead()
@warning_ignore("unused_signal")
signal gain_key()
@warning_ignore("unused_signal")
signal gain_item()
@warning_ignore("unused_signal")
signal toggle_map(on : bool)
@warning_ignore("unused_signal")
signal retreat()
@warning_ignore("unused_signal")
signal update_health()
@warning_ignore("unused_signal")
signal open_inventory()

var PlayerStats := {
  'Might': 2,
  'Agility': 1,
  'Arcana': 0,
  'Health': 6
}

var Weapons := {
  "Fist": {
    "damage": 1,
    "owned": true
  },
  "Knife": {
    "damage": 2,
  },
  "Lead Pipe": {
    "damage": 3,
  },
  "Pistol": {
    "damage": 2,
  },
  "Shotgun": {
    "damage": 4,
  }
}

var CurrentAction
var CurrentLoc : Vector2
var CurrentWeapon := "Fist"
var WeaponDamage := 1
var EncounterName
var EncounterHp : int

var my_roll : int
var my_total : int
var enemy_roll : int
var enemy_total : int
var roll_delta : int

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
  (SE_Corner + DOWN): preload("res://rooms/EmptyHall.tscn").instantiate(),
  SW_Corner: preload("res://rooms/EmptyHall.tscn").instantiate(),
  (SW_Corner + DOWN): preload("res://rooms/EmptyHall.tscn").instantiate(),
  (SW_Corner + LEFT): preload("res://rooms/EmptyHall.tscn").instantiate(),
  Center: preload("res://rooms/EmptyHall.tscn").instantiate(),
  (Center + LEFT): preload("res://rooms/EmptyHall.tscn").instantiate(),
  (Center + RIGHT): preload("res://rooms/RiddleHall.tscn").instantiate(),
  (Center + RIGHT + RIGHT): preload("res://rooms/EmptyHall.tscn").instantiate(),
  Back: preload("res://rooms/EmptyHall.tscn").instantiate(),
  (Back + UP): preload("res://rooms/EmptyHall.tscn").instantiate(),
  NE_Corner: preload("res://rooms/EmptyHall.tscn").instantiate(),
  (NE_Corner + UP): preload("res://rooms/EmptyHall.tscn").instantiate(),
  NW_Corner: preload("res://rooms/EmptyHall.tscn").instantiate(),
  (NW_Corner + UP): preload("res://rooms/EmptyHall.tscn").instantiate(),
  (NW_Corner + UP + LEFT): preload("res://rooms/EmptyHall.tscn").instantiate(),
}

var Keys := {
}
var riddle1 = false
var riddle2 = false
var riddle3 = false

var Doors := {
  [Start, Entrance]: 'Rusty Key',
  [Entrance, Center]: "Guard's Key",
  [Entrance, SW_Corner]: null,
  [SW_Corner, SW_Corner + DOWN]: null,
  [SW_Corner, SW_Corner + LEFT]: null,
  [Entrance, SE_Corner]: null,
  [SW_Corner, Center + LEFT]: null,
  [SE_Corner, Center + RIGHT]: null,
  [Center + RIGHT, Center + RIGHT + RIGHT]: "Witch's Key",
  [SE_Corner, SE_Corner + DOWN]: null,
  [NW_Corner, Center + LEFT]: null,
  [NE_Corner, Center + RIGHT]: null,
  [Back, Back + UP]: null,
  [NE_Corner, Back]: null,
  [NE_Corner, NE_Corner + UP]: null,
  [NW_Corner, Back]: null,
  [NW_Corner, NW_Corner + UP]: "Security Override B",
  [NW_Corner + UP, NW_Corner + UP + LEFT]: null,
}

func get_door(l1, l2):
  if Doors.has([l1, l2]):
    return [l1, l2];
  elif Doors.has([l2, l1]):
    return [l2, l1]
  return false;

var SeenRooms := {}
var CanMove := {}
