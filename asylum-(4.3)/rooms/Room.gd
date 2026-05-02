extends Node2D

@export var room_title : String
@export var room_diag : DialogueResource
@export var encounter : Node2D
var is_active = false
var player_diag : DialogueResource = preload('res://encounters/Player.dialogue')
var current_line : DialogueLine

func _ready():
  Global.room_enter.connect(enter)
  Global.room_investigate.connect(investigate)
  Global.choose.connect(choose)
  Global.enemy_dead.connect(end_encounter)
  DialogueManager.dialogue_ended.connect(_diag_end)
  DialogueManager.got_dialogue.connect(_diag_received)

func enter():
  if !is_active:
    return
  if encounter == null:
    Global.EncounterName = null
    Global.toggle_map.emit(true)
    DialogueManager.show_dialogue_balloon(room_diag, "intro")
  else:
    encounter.start()

func investigate():
  if !is_active:
    return
  DialogueManager.show_dialogue_balloon(room_diag, "investigate")
  
func move(_dir: Vector2):
  pass

func choose():
  if !is_active:
    return
  DialogueManager.show_dialogue_balloon(player_diag, "choose")

func end_encounter():
  if !is_active:
    return
  assert(encounter != null)
  encounter.queue_free()
  encounter = null
  Global.EnemiesKilled += 1
  enter()

func activate():
  is_active = true
  if encounter != null:
    encounter.is_active = true

func deactivate():
  is_active = false
  if encounter != null:
    encounter.is_active = false

func _diag_received(line):
  current_line = line

func _diag_end(node):
  if (node == room_diag and is_active):
    choose()
    
