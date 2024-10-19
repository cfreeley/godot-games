extends Node2D

@export var room_title : String
@export var room_diag : DialogueResource

#var Directions = {
  #"Up": Up,
  #"Down": Down,
  #"Left": Left,
  #"Right": Right,
#}

func _ready():
  Global.room_enter.connect(enter)
  Global.room_investigate.connect(investigate)

func enter():
  DialogueManager.show_dialogue_balloon(room_diag, "intro")

func investigate():
  DialogueManager.show_dialogue_balloon(room_diag, "investigate")
  
func move(dir: String):
  pass
  #if Directions[dir] != null:
    #Dungeon.enter_room(Directions[dir])
  
