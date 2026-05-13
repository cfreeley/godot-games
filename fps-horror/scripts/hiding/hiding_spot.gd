extends Area3D
class_name HidingSpot

## HidingSpot — A location the player can duck into to hide from enemies.
## Place in the scene, set hide_position to a child Marker3D node,
## and the player will be teleported to that point and locked in place.
## The interact() method is called by the player's interaction system.
##
## Examples: closets, under tables, inside lockers, behind rubble.

## Path to a child Marker3D that marks where the player stands while hidden.
@export var hide_position: NodePath = NodePath("")

## Optional rotation to force the player to face a specific direction while hidden.
@export var hide_rotation_degrees: Vector3 = Vector3.ZERO

## Interaction prompts shown in the HUD.
@export var enter_prompt: String = "Hide"
@export var exit_prompt: String  = "Leave hiding spot"

signal player_hidden(spot: HidingSpot)
signal player_revealed(spot: HidingSpot)

var _occupant: CharacterBody3D = null


func _ready() -> void:
	# Visualise the trigger area in the editor
	monitoring = true
	monitorable = false


func get_interaction_prompt() -> String:
	if _occupant != null:
		return "[E]  %s" % exit_prompt
	return "[E]  %s" % enter_prompt


func interact(player: CharacterBody3D) -> void:
	if _occupant == player:
		_exit_hiding(player)
	elif _occupant == null:
		_enter_hiding(player)


# ---------------------------------------------------------------------------
# Internal
# ---------------------------------------------------------------------------

func _enter_hiding(player: CharacterBody3D) -> void:
	_occupant = player

	# Move player to the defined hide position if one is set
	if hide_position != NodePath(""):
		var marker := get_node_or_null(hide_position) as Node3D
		if marker:
			player.global_position = marker.global_position
			player.rotation_degrees.y = hide_rotation_degrees.y

	GameManager.change_state(GameManager.State.HIDING)
	emit_signal("player_hidden", self)


func _exit_hiding(player: CharacterBody3D) -> void:
	_occupant = null
	GameManager.change_state(GameManager.State.EXPLORING)
	emit_signal("player_revealed", self)


func is_occupied() -> bool:
	return _occupant != null
