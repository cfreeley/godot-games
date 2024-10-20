extends Node2D

var CurrentRoom : Node2D

func _ready():
  $CanvasLayer/MainMenu.show()

func enter_room(loc):
  if CurrentRoom != null:
    remove_child(CurrentRoom)  
  CurrentRoom = Global.Map[loc]
  assert(CurrentRoom != null, "out of bounds at: %s" % loc)
  add_child(CurrentRoom)
  Global.CurrentLoc = loc
  Global.SeenRooms[loc] = true
  CurrentRoom.enter()

var input_to_dir = {
  "ui_up": Global.UP,
  "ui_down": Global.DOWN,
  "ui_left": Global.LEFT,
  "ui_right": Global.RIGHT,
}

func _unhandled_input(event):
  queue_redraw()
  if event.is_action_pressed("investigate"):
    CurrentRoom.investigate()
  else:
    for action in input_to_dir.keys():
      if event.is_action_pressed(action):
        var dir = input_to_dir[action]
        var new_loc = Global.CurrentLoc + dir
        var door = Global.get_door(Global.CurrentLoc, new_loc)
        if door and (Global.Doors[door] == null or Global.Keys.has(Global.Doors[door])):
          enter_room(new_loc)


func _on_start_button_pressed():
  enter_room(Global.Start)
  $CanvasLayer/MainMenu.hide()
  queue_redraw()  
