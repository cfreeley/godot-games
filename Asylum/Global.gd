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
@warning_ignore("unused_signal")
signal drink_fountain()
@warning_ignore("unused_signal")
signal toggle_switch(value)
@warning_ignore("unused_signal")
signal stat_boost(stat)
@warning_ignore("unused_signal")
signal get_pistol()
@warning_ignore("unused_signal")
signal get_pistol_ammo(amount)
@warning_ignore("unused_signal")
signal weapon_change(source)
@warning_ignore("unused_signal")
signal game_end(source)

var PlayerStats := {
  'Might': 2,
  'Agility': 1,
  'Arcana': 0,
  'Health': 6,
  'Corruption': 0,
}

var Weapons := {
  "Fist": {
    "damage": 1,
    "type": "melee",
    "owned": true
  },
  "Knife": {
    "damage": 2,
    "type": "melee",
  },
  "Pipe": {
    "damage": 3,
    "type": "melee",
  },
  "Pistol": {
    "damage": 2,
    "type": "ranged",
    "ammo": 0
  },
  "Shotgun": {
    "damage": 4,
    "type": "ranged",
    "ammo": 0
  }
}

func get_ammo():
  return Weapons[CurrentWeapon].get("ammo")

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
var roll_outcome : String

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
  SE_Corner: preload("res://rooms/ScratchedJunction.tscn").instantiate(),
  (SE_Corner + DOWN): preload("res://rooms/Sanctum.tscn").instantiate(),
  SW_Corner: preload("res://rooms/EmptyHall.tscn").instantiate(),
  (SW_Corner + DOWN): preload("res://rooms/RadioCell.tscn").instantiate(),
  (SW_Corner + LEFT): preload("res://rooms/AnarchistRoom.tscn").instantiate(),
  Center: preload("res://rooms/BasementStairway.tscn").instantiate(),
  (Center + LEFT): preload("res://rooms/ScratchedJunction.tscn").instantiate(),
  (Center + RIGHT): preload("res://rooms/RiddleHall.tscn").instantiate(),
  (Center + RIGHT + RIGHT): preload("res://rooms/PaddedRoom.tscn").instantiate(),
  Back: preload("res://rooms/DamagedHall.tscn").instantiate(),
  (Back + UP): preload("res://rooms/Office.tscn").instantiate(),
  NE_Corner: preload("res://rooms/NortheastCorner.tscn").instantiate(),
  (NE_Corner + UP): preload("res://rooms/ControlRoom.tscn").instantiate(),
  NW_Corner: preload("res://rooms/NorthwestCorner.tscn").instantiate(),
  (NW_Corner + UP): preload("res://rooms/ObservationRoom.tscn").instantiate(),
  (NW_Corner + UP + LEFT): preload("res://rooms/SecureContainment.tscn").instantiate(),
}

var Keys := {}
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
  [NW_Corner, NW_Corner + UP]: "Observation Lock Release",
  [NW_Corner + UP, NW_Corner + UP + LEFT]: "Containment Lock Release",
}

func get_door(l1, l2):
  if Doors.has([l1, l2]):
    return [l1, l2];
  elif Doors.has([l2, l1]):
    return [l2, l1]
  return false;

func door_unlocked(door):
  var key = Doors[door]
  var hidden_key = "%s$HIDE" % key
  return Keys.has(key) or Keys.has(hidden_key)

var SeenRooms := {}
var CanMove := {}
var HasIncantation := false
var HasHeardRadio := false
var HasMolotov = null
var RemainingTears := 3
var HasBoost := false
var HasLootedPistolAmmo = false

var GuardStatus = "locked" # "escaped" | "dead" | "locked"
var DoorStatus # "containment" | "observation" | "both"
