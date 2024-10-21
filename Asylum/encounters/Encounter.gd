extends Node2D

@export var texture : Texture2D
@export var title : String
@export var diag : DialogueResource
@export var en_hp : int # initial hp
@export var en_might : int
@export var en_agility : int
@export var en_dmg : int
var en_hostile = true
var is_active = false

var player_diag : DialogueResource = preload('res://encounters/Player.dialogue')
var current_line : DialogueLine
var balloon

func _ready():
  $Sprite2D.texture = texture
  DialogueManager.dialogue_ended.connect(_diag_end)
  DialogueManager.got_dialogue.connect(_diag_received)

func start():
  Global.toggle_map.emit(false)
  Global.EncounterName = title
  Global.EncounterHp = en_hp
  en_hostile = true
  $AnimationPlayer.play("fadein")
  balloon = DialogueManager.show_dialogue_balloon(diag, "intro" )

func _diag_end(diagResource):
  if !is_active:
    return;
  if (diagResource == diag):
    DialogueManager.show_dialogue_balloon(player_diag, "combat" )
  elif diagResource == player_diag && Global.CurrentAction != null:
    match Global.CurrentAction:
      "attack":
        attack()
      "evade":
        evade()
      "retreat":
        retreat()
    Global.CurrentAction = null
  elif Global.CurrentAction == null:
    if Global.PlayerStats.Health <= 0:
      print("Game over")
    elif Global.EncounterHp <= 0:
      $AnimationPlayer.play_backwards("fadein")
    elif !balloon && en_hostile: # witchcraft :(
      DialogueManager.show_dialogue_balloon(player_diag, "combat")
    elif !en_hostile:
      $AnimationPlayer.play_backwards("fadein")
    

func roll():
  return randi_range(1,6)

func attack():
  Global.my_roll = roll();
  Global.my_total = Global.my_roll + Global.PlayerStats.Might
  Global.enemy_roll = roll();
  Global.enemy_total = Global.enemy_roll + en_might;
  Global.roll_delta = Global.my_total - Global.enemy_total
  if Global.roll_delta < 3:
    Global.PlayerStats.Health -= en_dmg
    Global.update_health.emit()
  if Global.roll_delta >= 0:
    Global.EncounterHp -= Global.WeaponDamage
  DialogueManager.show_dialogue_balloon(player_diag, "attack")

func evade():
  Global.my_roll = roll();
  Global.my_total = Global.my_roll + Global.PlayerStats.Agility
  Global.enemy_roll = roll();
  Global.enemy_total = Global.enemy_roll + en_agility;
  Global.roll_delta = Global.my_total - Global.enemy_total
  if Global.roll_delta < 3:
    Global.PlayerStats.Health -= en_dmg
    Global.update_health.emit()
  if Global.roll_delta >= 0:
    en_hostile = false
  DialogueManager.show_dialogue_balloon(player_diag, "evade")

func retreat():
  Global.retreat.emit()

func _diag_received(line):
  current_line = line

func _on_animation_player_animation_finished(anim_name):
  if Global.EncounterHp <= 0:
    Global.enemy_dead.emit()
  elif !en_hostile:
    Global.toggle_map.emit(true)
    Global.choose.emit()
