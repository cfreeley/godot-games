extends Node3D
class_name ItemBase

## ItemBase — Base class for any interactable object in the world.
## Extend this for keys, pickups, doors, switches, notes, etc.
## The player's InteractionRay calls get_interaction_prompt() and interact().

@export var item_id: String = ""
@export var item_name: String = "Unknown Item"
@export_multiline var item_description: String = ""
@export var interaction_prompt: String = "Examine"

## Emitted whenever a player interacts with this item.
signal interacted(item: ItemBase, player: CharacterBody3D)


func get_interaction_prompt() -> String:
	return "[E]  %s" % item_name


func interact(player: CharacterBody3D) -> void:
	emit_signal("interacted", self, player)
	_on_interact(player)


## Override in subclasses to define what happens on interaction.
func _on_interact(_player: CharacterBody3D) -> void:
	pass
