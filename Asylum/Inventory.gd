extends Control

var bgroup = ButtonGroup.new()

func _ready():
  bgroup.pressed.connect(_on_weapon_select)
  
func _on_weapon_select(node):
  var weapon = node.text.split(" ")[0]
  Global.weapon_change.emit()
  Global.CurrentWeapon = weapon
  Global.WeaponDamage = Global.Weapons[weapon].get("damage")

func _on_visibility_changed():
  var stats_text = "Health: %s\nMight: %s\nAgility: %s\nArcana: %s" % [Global.PlayerStats.Health, 
    Global.PlayerStats.Might, Global.PlayerStats.Agility, Global.PlayerStats.Arcana]
  if Global.PlayerStats.Corruption > 0:
    stats_text += "\nCorruption: %s" % Global.PlayerStats.Corruption
  $MarginContainer/VBoxContainer/Stats.text = stats_text
  for child in $MarginContainer/VBoxContainer/HBoxContainer/Keys/Items.get_children():
    child.queue_free()
  for child in $MarginContainer/VBoxContainer/HBoxContainer/Inventory/Items.get_children():
    child.queue_free()
  for weapon in Global.Weapons.keys():
    if !Global.Weapons[weapon].get('owned'):
      continue
    var box = CheckBox.new()
    box.name = weapon
    box.text = "%s (%s DMG %s)" % [weapon, 
      Global.Weapons[weapon].get('damage'), Global.Weapons[weapon].get('type')]
    box.button_group = bgroup
    box.button_pressed = Global.CurrentWeapon == weapon
    $MarginContainer/VBoxContainer/HBoxContainer/Inventory/Items.add_child(box)
    print(box.name)
  for key in Global.Keys.keys():
    if key.contains("$HIDE"):
      continue
    var box = Label.new()
    box.text = key
    $MarginContainer/VBoxContainer/HBoxContainer/Keys/Items.add_child(box)
    
  var PistolAmmoLabel = Label.new()
  PistolAmmoLabel.text = "Pistol ammo (%s)" % Global.Weapons.Pistol.ammo
  if Global.Weapons.Pistol.get('owned') or Global.Weapons.Pistol.ammo > 0:
    $MarginContainer/VBoxContainer/HBoxContainer/Inventory/Items.add_child(PistolAmmoLabel)

  var ShotgunAmmoLabel = Label.new()
  ShotgunAmmoLabel.text = "Shotgun ammo (%s)" % Global.Weapons.Shotgun.ammo
  if Global.Weapons.Shotgun.get('owned') or Global.Weapons.Shotgun.ammo > 0:
    $MarginContainer/VBoxContainer/HBoxContainer/Inventory/Items.add_child(ShotgunAmmoLabel)
  
  var MolotovLabel = Label.new()
  MolotovLabel.text = "Molotov Cocktail"
  if Global.HasMolotov == true:
    $MarginContainer/VBoxContainer/HBoxContainer/Inventory/Items.add_child(MolotovLabel)
