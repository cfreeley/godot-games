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
@warning_ignore("unused_signal")
signal reset(from_save)
@warning_ignore("unused_signal")
signal load_game(file)

var CleanSave
var QuickSave
func _ready():
  CleanSave = serialize()

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

var CurrentAction
var CurrentLoc = Start
var CurrentWeapon := "Fist"
var WeaponDamage := 1
var EncounterName
var EncounterHp : int

var BasementTemplate := {
  Start: ("res://rooms/PlayerCell.tscn"),
  Entrance: ("res://rooms/EntranceWay.tscn"),
  SE_Corner: ("res://rooms/ScratchedJunction.tscn"),
  (SE_Corner + DOWN): ("res://rooms/Sanctum.tscn"),
  SW_Corner: ("res://rooms/EmptyHall.tscn"),
  (SW_Corner + DOWN): ("res://rooms/RadioCell.tscn"),
  (SW_Corner + LEFT): ("res://rooms/AnarchistRoom.tscn"),
  Center: ("res://rooms/BasementStairway.tscn"),
  (Center + LEFT): ("res://rooms/ScratchedJunction.tscn"),
  (Center + RIGHT): ("res://rooms/RiddleHall.tscn"),
  (Center + RIGHT + RIGHT): ("res://rooms/PaddedRoom.tscn"),
  Back: ("res://rooms/DamagedHall.tscn"),
  (Back + UP): ("res://rooms/Office.tscn"),
  NE_Corner: ("res://rooms/NortheastCorner.tscn"),
  (NE_Corner + UP): ("res://rooms/ControlRoom.tscn"),
  NW_Corner: ("res://rooms/NorthwestCorner.tscn"),
  (NW_Corner + UP): ("res://rooms/ObservationRoom.tscn"),
  (NW_Corner + UP + LEFT): ("res://rooms/SecureContainment.tscn"),
}

var Map := {}
var MapMemory := {}

func init_map(template : Dictionary):
  Map = {}
  for key in template.keys():
    Map[key] = load(template[key]).instantiate()
    if Map[key].get("encounter") and MapMemory.has(key):
      if MapMemory.get(key) == null:
        Map[key].encounter.queue_free()
        Map[key].encounter = null
      else:
        Map[key].encounter.en_hp = MapMemory[key].en_hp
  for x in Map.keys():
    print(Map[x].encounter)


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
var SaveCount = 0
var EnemiesKilled = 0
var Ending : String
var EndingNum : int
var skip_to_start = false
var GuardStatus = "locked" # "escaped" | "dead" | "locked"
var DoorStatus # "containment" | "observation" | "both"

var banned := ["Global.gd", "CleanSave", "QuickSave"]
func serialize():
  var empty = Node.new()
  var data = {}
  for prop in Global.get_property_list():
    var pname = prop.name
    if banned.has(pname) or empty.get_property_list().any(func(p): return p.name == pname):
      continue
    data[pname] = Global[pname]

  data.Map = {}
  for key in Map:
    data.MapMemory[key] = null if Map[key].get('encounter') == null else { "en_hp": Map[key].encounter.en_hp }
  return var_to_bytes(data)
  
func load(serial):
  var data = bytes_to_var(serial)
  for key in data:
    var value = data[key]
    Global[key] = value
  get_tree().change_scene_to_file("res://Dungeon.tscn")
  
