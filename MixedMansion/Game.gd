extends Node

enum Skills {
	might,
	agility,
	perception,
	will
}
enum Results {
	Pass,
	Partial,
	Fail
}
var stats = {
	Skills.might: 0,
	Skills.agility: -1,
	Skills.perception: 1,
	Skills.will: 2
}

var CELL_LEN = 60
var selected_obj
var context_actions
var random
var manor

func _ready():
	random = RandomNumberGenerator.new()
	random.randomize()

func click_object(event, caller, n, desc):
	logMessage(str(n, ": ", desc))

func open_actions(event, caller, actions):
	$GUI/ContextMenu.position = caller.position
	var popup = PopupMenu.new()
	$GUI/ContextMenu.add_child(popup)
	popup.set_position(event.position)
	for n in actions.size():
		popup.add_item(actions[n], n, n)
	popup.connect("id_pressed", self, "on_context_action_pressed")
	popup.popup()
	context_actions = actions
	selected_obj = caller

func on_context_action_pressed(id):
	var action = context_actions[id]
	if (selected_obj.has_method(action)):
		selected_obj.call(action)
	else:
		logMessage(str("Unable to ", action))

func _on_HighliteButton_button_down():
	get_tree().call_group("interactable", "toggle_highlite", true)

func _on_HighliteButton_button_up():
	get_tree().call_group("interactable", "toggle_highlite", false)

func skill_check(bonus):
	var d1 = random.randi_range(1,6)
	var d2 = random.randi_range(1,6)
	var res = d1 + d2 + bonus
	var bonus_str = str(" + ", bonus) if bonus >= 0 else str(" - ", -bonus)
	logMessage(str("(", d1, " + ", d2, ")", bonus_str, " = ", res))
	if (res >= 10):
		return Results.Pass
	elif (res >= 7):
		return Results.Partial
	else:
		return Results.Fail

func logMessage(message):
	$GUI/Terminal.text += str(message, '\n')
