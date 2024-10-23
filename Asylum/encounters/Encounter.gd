extends Node2D

@export var texture : Texture2D
@export var title : String
@export var diag : DialogueResource
@export var en_name : String
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
  Global.open_inventory.connect(on_inventory)
  get_tree().get_root().size_changed.connect(resize)
  resize()

func resize():
  $Sprite2D.position.x = get_viewport_rect().size.x / 2
  $Sprite2D.position.y = get_viewport_rect().size.y * .375

func start():
  Global.toggle_map.emit(false)
  Global.EncounterName = title
  Global.EncounterHp = en_hp
  en_hostile = true
  $AnimationPlayer.play("fadein")
  balloon = DialogueManager.show_dialogue_balloon(player_diag, en_name )
  
func on_inventory(vis):
  visible = !vis

func _diag_end(diagResource):
  if !is_active:
    return;
  if diagResource == player_diag && Global.CurrentAction != null:
    match Global.CurrentAction:
      "attack":
        attack()
      "evade":
        evade()
      "retreat":
        retreat()
      "shoot":
        shoot()
      "grenade":
        grenade()
      "spell":
        spell()
    Global.CurrentAction = null
  elif Global.CurrentAction == null:
    if Global.PlayerStats.Health <= 0:
      Global.game_end.emit("death")
    elif Global.EncounterHp <= 0:
      $AnimationPlayer.play_backwards("fadein")
    elif !balloon && en_hostile: # witchcraft :(
      DialogueManager.show_dialogue_balloon(player_diag, "combat")
    elif !en_hostile:
      $AnimationPlayer.play_backwards("fadein")
    

func roll():
  return randi_range(1,6)

func update_roll_outcome():
  var roll_label = "+%s" % Global.roll_delta if Global.roll_delta > 0 else str(Global.roll_delta) 
  if Global.roll_delta >= 3:
    Global.roll_outcome = "%s: total success." % roll_label
  elif Global.roll_delta >= 0:
    Global.roll_outcome = "%s: mixed success." % roll_label
  else:
    Global.roll_outcome = "%s: failure." % roll_label

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
  update_roll_outcome()
  DialogueManager.show_dialogue_balloon(player_diag, "attack")

func shoot():
  Global.Weapons[Global.CurrentWeapon].ammo -= 1
  Global.EncounterHp -= Global.WeaponDamage
  DialogueManager.show_dialogue_balloon(player_diag, "shoot")

func grenade():
  Global.HasMolotov = false
  Global.EncounterHp -= 6
  DialogueManager.show_dialogue_balloon(player_diag, "grenade")

func spell():
  Global.my_roll = roll();
  Global.my_total = Global.my_roll + Global.PlayerStats.Arcana
  Global.enemy_roll = roll();
  Global.enemy_total = Global.enemy_roll - Global.PlayerStats.Arcana;
  Global.roll_delta = Global.my_total - Global.enemy_total
  if Global.roll_delta < 3:
    Global.PlayerStats.Corruption += 1
  if Global.roll_delta >= 0:
    Global.EncounterHp -= 5
  update_roll_outcome()
  DialogueManager.show_dialogue_balloon(player_diag, "spell")

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
  update_roll_outcome()
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
