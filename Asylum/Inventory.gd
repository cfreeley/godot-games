extends Control

var bgroup = ButtonGroup.new()

func _ready():
  bgroup.pressed.connect(_on_weapon_select)
  
func _on_weapon_select(node):
  Global.CurrentWeapon = node.text
  Global.WeaponDamage = Global.Weapons[node.text].get("damage")

func _on_visibility_changed():
  for child in $MarginContainer/VBoxContainer/HBoxContainer/Keys/Items.get_children():
    child.queue_free()
  for child in $MarginContainer/VBoxContainer/HBoxContainer/Inventory/Items.get_children():
    child.queue_free()
  for weapon in Global.Weapons.keys():
    print(weapon, Global.Weapons[weapon])
    if !Global.Weapons[weapon].get('owned'):
      continue
    var box = CheckBox.new()
    box.text = weapon
    box.button_group = bgroup
    box.button_pressed = Global.CurrentWeapon == weapon
    $MarginContainer/VBoxContainer/HBoxContainer/Inventory/Items.add_child(box)
  for key in Global.Keys.keys():
    var box = Label.new()
    box.text = key
    $MarginContainer/VBoxContainer/HBoxContainer/Keys/Items.add_child(box)
    
