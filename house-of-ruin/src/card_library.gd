extends Node

var cards: Dictionary = {}  # id -> CardData

func _ready() -> void:
	_load_cards()

func _load_cards() -> void:
	var file := FileAccess.open("res://data/cards.json", FileAccess.READ)
	if not file:
		push_error("CardLibrary: could not open res://data/cards.json")
		return
	var json := JSON.new()
	var err := json.parse(file.get_as_text())
	if err != OK:
		push_error("CardLibrary: JSON parse error: " + json.get_error_message())
		return
	for entry in json.get_data():
		var cd := CardData.new()
		cd.id = entry.get("id", "")
		cd.card_name = entry.get("name", "")
		cd.rarity = entry.get("rarity", "common")
		cd.cost = _int_values(entry.get("cost", {}))
		cd.produces = _int_values(entry.get("produces", {}))
		cd.threat_chance = entry.get("threat_chance", 0.0)
		cd.card_effect = entry.get("card_effect", "")
		cd.description = entry.get("description", "")
		cards[cd.id] = cd
	print("CardLibrary: loaded %d cards" % cards.size())

func _int_values(d: Dictionary) -> Dictionary:
	var result := {}
	for k in d:
		result[k] = int(d[k])
	return result

func get_all() -> Array:
	return cards.values()

func get_by_id(id: String) -> CardData:
	return cards.get(id, null)

func get_random_draft(count: int = 3) -> Array:
	var pool := get_all().duplicate()
	pool.shuffle()
	return pool.slice(0, min(count, pool.size()))
