extends "res://Tile.gd"

var messages: Array

func _ready():
	pass

func _process(delta):
	if (destination == position):
		read_input()

func read_input():
	if (Input.is_action_pressed("ui_up")):
		move_from_dir(DIRECTION.UP)
	elif (Input.is_action_pressed("ui_right")):
		move_from_dir(DIRECTION.RIGHT)
	elif (Input.is_action_pressed("ui_down")):
		move_from_dir(DIRECTION.DOWN)
	elif (Input.is_action_pressed("ui_left")):
		move_from_dir(DIRECTION.LEFT)
	
	if (Input.is_action_just_pressed("ui_accept")):
		var target = GRID.get_cell(to_cell(next_cell_from_dir()))
		if (target and funcref(target, "interact")):
			var result = target.interact(self)
			var type = result[0]
			var value = result[1]
			match type:
				"dialogue":
					open_dialogue(value)

func open_dialogue(msg):
	messages = msg.duplicate()
	$DialogueBox/VBoxContainer/MessageLabel.text = messages[0]
	get_tree().paused = true
	$DialogueBox.visible = true


func _on_OkayButton_pressed():
	messages.pop_front()
	if (messages.size() == 0):
		get_tree().paused = false
		$DialogueBox.visible = false
	else:
		$DialogueBox/VBoxContainer/MessageLabel.text = messages[0]
