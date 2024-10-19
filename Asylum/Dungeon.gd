extends Node2D

@export var InitialRoom : PackedScene
var CurrentRoom : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
  enter_room(InitialRoom)

func enter_room(room): 
  if CurrentRoom != null:
    CurrentRoom.free()
  add_child(room.instantiate())
  Global.room_enter.emit()

var input_to_dir = {
  "ui_up": "Up",
  "ui_down": "Down",
  "ui_left": "Left",
  "ui_right": "Right",
}

func _unhandled_input(event):
  if event.is_action_pressed("investigate"):
    Global.room_investigate.emit()
  else:
    for action in input_to_dir.keys():
      if event.is_action_pressed(action):
        Global.room_move.emit(input_to_dir[action])
