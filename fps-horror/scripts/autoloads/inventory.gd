extends Node

## Inventory — Autoload singleton
## Tracks every item the player has collected.
## Items are stored by string ID so they can be checked from anywhere
## (e.g. "does the player have the basement_key?").

signal item_added(item_id: String, item_name: String)
signal item_removed(item_id: String)
signal inventory_changed

## item_id -> { name, description, quantity }
var _items: Dictionary = {}


# ---------------------------------------------------------------------------
# Add / Remove
# ---------------------------------------------------------------------------

func add_item(item_id: String, item_name: String, description: String = "", quantity: int = 1) -> void:
	if _items.has(item_id):
		_items[item_id].quantity += quantity
	else:
		_items[item_id] = {
			"name": item_name,
			"description": description,
			"quantity": quantity,
		}
	emit_signal("item_added", item_id, item_name)
	emit_signal("inventory_changed")


func remove_item(item_id: String, quantity: int = 1) -> bool:
	if not _items.has(item_id):
		return false
	_items[item_id].quantity -= quantity
	if _items[item_id].quantity <= 0:
		_items.erase(item_id)
	emit_signal("item_removed", item_id)
	emit_signal("inventory_changed")
	return true


# ---------------------------------------------------------------------------
# Queries
# ---------------------------------------------------------------------------

func has_item(item_id: String) -> bool:
	return _items.has(item_id) and _items[item_id].quantity > 0


func get_item_count(item_id: String) -> int:
	if not _items.has(item_id):
		return 0
	return _items[item_id].quantity


func get_item_data(item_id: String) -> Dictionary:
	return _items.get(item_id, {})


func get_all_items() -> Dictionary:
	return _items.duplicate(true)


func get_item_count_total() -> int:
	var total := 0
	for id in _items:
		total += _items[id].quantity
	return total


# ---------------------------------------------------------------------------
# Utility
# ---------------------------------------------------------------------------

func clear() -> void:
	_items.clear()
	emit_signal("inventory_changed")
