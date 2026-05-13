extends ItemBase
class_name PickupItem

## PickupItem — An item the player can pick up.
## On interact, it is added to Inventory and (optionally) removed from the world.

## If true, the node is freed after pickup.
@export var auto_collect: bool = true
@export var quantity: int = 1

signal collected(item_id: String, item_name: String)


func get_interaction_prompt() -> String:
	return "[E]  Pick up  %s" % item_name


func _on_interact(_player: CharacterBody3D) -> void:
	Inventory.add_item(item_id, item_name, item_description, quantity)
	emit_signal("collected", item_id, item_name)

	if auto_collect:
		# Optional: play a pickup sound/animation before freeing
		queue_free()
