extends Node2D

@export var room_title : String
@export var room_diag : DialogueResource
@export var encounter : Node2D

func _ready():
  Global.room_enter.connect(enter)
  Global.room_investigate.connect(investigate)

func enter():
  if encounter == null:
    DialogueManager.show_dialogue_balloon(room_diag, "intro")
  else:
    encounter.start()

func investigate():
  DialogueManager.show_dialogue_balloon(room_diag, "investigate")
  
func move(dir: String):
  pass
  
