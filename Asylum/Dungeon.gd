extends Node2D

var CurrentLoc : Vector2
var CurrentRoom : Node2D

var Start = Vector2(0,0)
var LEFT = Vector2(-1, 0)
var RIGHT = Vector2(1, 0)
var UP = Vector2(0, 1)
var DOWN = Vector2(0, -1)

var Map := {
  Start: preload("res://rooms/PlayerCell.tscn").instantiate(),
  (Start + UP): preload("res://rooms/EntranceWay.tscn").instantiate(),
}

func _ready():
  $CanvasLayer/MainMenu.show()

func enter_room(loc):
  if CurrentRoom != null:
    remove_child(CurrentRoom)  
  CurrentRoom = Map[loc]
  assert(CurrentRoom != null, "out of bounds at: %s" % loc)
  add_child(CurrentRoom)
  CurrentLoc = loc
  CurrentRoom.enter()

var input_to_dir = {
  "ui_up": UP,
  "ui_down": DOWN,
  "ui_left": LEFT,
  "ui_right": RIGHT,
}

func _unhandled_input(event):
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
