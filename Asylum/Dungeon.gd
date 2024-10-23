extends Node2D

var CurrentRoom : Node2D
var LastLoc : Vector2
var endings = preload("res://GameEndings.dialogue")

func _ready():
  Global.init_map(Global.BasementTemplate)
  $CanvasLayer/MainMenu.show()
  Global.room_move.connect(move_by)
  Global.gain_key.connect(get_key)
  Global.gain_item.connect(get_item)
  Global.toggle_map.connect(toggle_map)
  Global.retreat.connect(retreat)
  Global.update_health.connect(update_health)
  Global.drink_fountain.connect(drink_fountain)
  Global.toggle_switch.connect(toggle_switch)
  Global.stat_boost.connect(stat_boost)
  Global.get_pistol.connect(get_pistol)
  Global.get_pistol_ammo.connect(get_pistol_ammo)
  Global.weapon_change.connect(update_weapon)
  Global.game_end.connect(game_end)
  Global.reset.connect(reset)
  if Global.skip_to_start:
    _on_start_button_pressed()
  Global.skip_to_start = true

func game_end(source):
  CurrentRoom.deactivate()
  if CurrentRoom.encounter != null:
    CurrentRoom.encounter.get_node("AnimationPlayer").play_backwards("fadein")
  var end = source
  if source == 'stairs':
    end = "arrest" if Global.GuardStatus == 'escaped' else "fire"
  if end == "fire" or end == "corruption":
    $CanvasLayer/SecretEncounter.get_node("AnimationPlayer").play("fadein")
    $CanvasLayer/SecretEncounter.visible = true
  Global.Ending = end
  Global.EndingNum = ["death", "corruption", "arrest", "fire"].find(end)
  DialogueManager.show_dialogue_balloon(endings, end)

func reset(from_save):
  var save = Global.QuickSave if from_save and Global.QuickSave != null else Global.CleanSave
  Global.load(save)

func get_key(key):
  Global.Keys[key] = true
  update_can_move()

func get_item(item):
  Global.Weapons[item].owned = true
  
func get_pistol():
  Global.Weapons.Pistol["owned"] = true
  Global.Weapons.Pistol.ammo += 4
  
func get_pistol_ammo(amount):
  Global.Weapons.Pistol.ammo += amount
  Global.HasLootedPistolAmmo = true

func stat_boost(stat):
  Global.PlayerStats[stat] += 1
  Global.HasBoost = true

func drink_fountain():
  Global.RemainingTears -= 1
  Global.PlayerStats.Health = 7
  update_health()

func move_by(dir):
  enter_room(Global.CurrentLoc + dir)
  
func retreat():
  enter_room(LastLoc)

func toggle_switch(value):
  Global.DoorStatus = value
  if value == "containment" or value == "both":
    Global.Keys["Containment Lock Release$HIDE"] = true
    if Global.GuardStatus != "escaped":
      Global.GuardStatus = "dead"
      
  if value == "observation" or value == "both":
    Global.Keys["Observation Lock Release$HIDE"] = true
    if value == "observation" and Global.GuardStatus == "locked":
      Global.Keys["Guard's Key$HIDE"] = true
      Global.GuardStatus = "escaped"
     
  update_can_move()

func update_can_move():
  Global.CanMove = {}
  for dir in input_to_dir.values():
      var new_loc = Global.CurrentLoc + dir
      var door = Global.get_door(Global.CurrentLoc, new_loc)
      if door and (Global.Doors[door] == null or Global.door_unlocked(door)):
        Global.CanMove[dir] = true

func enter_room(loc):
  if CurrentRoom != null:
    CurrentRoom.deactivate()
    remove_child(CurrentRoom)  
  CurrentRoom = Global.Map[loc]
  assert(CurrentRoom != null, "out of bounds at: %s" % loc)
  add_child(CurrentRoom)
  CurrentRoom.activate()
  LastLoc = Global.CurrentLoc
  Global.CurrentLoc = loc
  Global.SeenRooms[loc] = true
  update_can_move()
  $CanvasLayer/GUI/Panel/HBoxContainer/RoomLabel.text = CurrentRoom.room_title
  CurrentRoom.enter()

var input_to_dir = {
  "ui_up": Global.UP,
  "ui_down": Global.DOWN,
  "ui_left": Global.LEFT,
  "ui_right": Global.RIGHT,
}

func _on_start_button_pressed():
  enter_room(Global.CurrentLoc)
  $CanvasLayer/MainMenu.hide()
  $CanvasLayer/GUI.show()
  update_health()
  queue_redraw()  

func toggle_map(on):
  $CanvasLayer/Map.visible = true
  if on and $CanvasLayer/Map.modulate.a == 0:
    $CanvasLayer/AnimationPlayer.play("fadein")
  elif !on and $CanvasLayer/Map.modulate.a == 1:
    $CanvasLayer/AnimationPlayer.play_backwards("fadein")

func update_health():
  $CanvasLayer/GUI/Panel/HBoxContainer/HealthLabel.text = "%s HP" % Global.PlayerStats.Health

func update_weapon():
  $CanvasLayer/GUI/Panel/HBoxContainer/WeaponLabel.text = "Weapon: %s" % Global.CurrentWeapon

func _on_inventory_button_pressed():
  var visible = !$CanvasLayer/Menu.visible
  $CanvasLayer/Menu.visible = visible
  $CanvasLayer/Map.visible = !visible
  Global.open_inventory.emit(visible)


func _on_save_button_pressed():
  Global.QuickSave = Global.serialize()
  Global.SaveCount += 1
