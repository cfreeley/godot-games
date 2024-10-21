extends Control

func _on_visibility_changed():
  for child in $MarginContainer/VBoxContainer/HBoxContainer/Keys/Items.get_children():
    child.queue_free()
  for child in $MarginContainer/VBoxContainer/HBoxContainer/Inventory/Items.get_children():
    child.queue_free()
  var group = ButtonGroup.new()
  for weapon in Global.Weapons.keys():
    if !Global.Weapons.get('owned'):
      continue
    var box = CheckBox.new()
    box.text = weapon
    box.group = group
    $MarginContainer/VBoxContainer/HBoxContainer/Inventory/Items.add_child(box)
  for key in Global.Keys.keys():
    var box = Label.new()
    box.text = key
    $MarginContainer/VBoxContainer/HBoxContainer/Keys/Items.add_child(box)
    
