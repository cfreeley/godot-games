extends Node2D

var CurrentRoom : Node2D
var LastLoc : Vector2

func _ready():
  $CanvasLayer/MainMenu.show()
  Global.room_move.connect(move_by)
  Global.gain_key.connect(get_key)
  Global.gain_item.connect(get_item)
  Global.toggle_map.connect(toggle_map)
  Global.retreat.connect(retreat)
  Global.update_health.connect(update_health)

func get_key(key):
  Global.Keys[key] = true
  update_can_move()

func get_item(item):
  Global.Weapons[item].owned = true
  print(Global.Weapons[item], item)

func move_by(dir):
  print('move')
  enter_room(Global.CurrentLoc + dir)
  
func retreat():
  enter_room(LastLoc)
  
func update_can_move():
  Global.CanMove = {}
  for dir in input_to_dir.values():
      var new_loc = Global.CurrentLoc + dir
      var door = Global.get_door(Global.CurrentLoc, new_loc)
      if door and (Global.Doors[door] == null or Global.Keys.has(Global.Doors[door])):
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
  print(Global.CanMove)
  $CanvasLayer/GUI/Panel/HBoxContainer/RoomLabel.text = CurrentRoom.room_title
  CurrentRoom.enter()

var input_to_dir = {
  "ui_up": Global.UP,
  "ui_down": Global.DOWN,
  "ui_left": Global.LEFT,
  "ui_right": Global.RIGHT,
}

#func _unhandled_input(event):
  #if event.is_action_pressed("investigate"):
    #CurrentRoom.investigate()
  #else:
    #for action in input_to_dir.keys():
      #if event.is_action_pressed(action):
        #var dir = input_to_dir[action]
        #var new_loc = Global.CurrentLoc + dir
        #var door = Global.get_door(Global.CurrentLoc, new_loc)
        #if door and (Global.Doors[door] == null or Global.Keys.has(Global.Doors[door])):
          #enter_room(new_loc)

func _on_start_button_pressed():
  enter_room(Global.Start)
  $CanvasLayer/MainMenu.hide()
  $CanvasLayer/GUI.show()
  update_health()
  queue_redraw()  

func toggle_map(on):
  $CanvasLayer/Map.visible = true
  print($CanvasLayer/Map.modulate.a)
  if on and $CanvasLayer/Map.modulate.a == 0:
    $CanvasLayer/AnimationPlayer.play("fadein")
  elif !on and $CanvasLayer/Map.modulate.a == 1:
    $CanvasLayer/AnimationPlayer.play_backwards("fadein")

func update_health():
  $CanvasLayer/GUI/Panel/HBoxContainer/HealthLabel.text = "%s HP" % Global.PlayerStats.Health


func _on_inventory_button_pressed():
  var visible = !$CanvasLayer/Menu.visible
  $CanvasLayer/Menu.visible = visible
  $CanvasLayer/Map.visible = !visible
  Global.open_inventory.emit(visible)
