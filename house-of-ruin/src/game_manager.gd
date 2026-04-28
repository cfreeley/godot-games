extends Node

signal phase_changed(phase: Phase)
signal resources_changed()
signal threat_spawned(tile_id: String)
signal threat_resolved(tile_id: String)
signal tile_draft_selected(card: CardData)
signal starting_tile_registered(card: CardData)
signal log_message(text: String)
signal run_ended(won: bool)

enum Phase { BUILD, LIVING }

const MAX_HP := 20
const STARTING_ROOM_ID := "entrance_hall"

var current_phase: Phase = Phase.BUILD
var resources: Dictionary = {"gold": 5, "arcana": 0, "insight": 0}
var hp: int = MAX_HP
var tiles_placed: Array[CardData] = []
var active_threats: Array[String] = []
var turn_number: int = 0
var pending_tile: CardData = null

func start_run() -> void:
	resources = {"gold": 5, "arcana": 0, "insight": 0}
	hp = MAX_HP
	tiles_placed.clear()
	active_threats.clear()
	turn_number = 0
	pending_tile = null
	DeckManager.deck.clear()
	DeckManager.hand.clear()
	DeckManager.discard.clear()

	var starting_card := CardLibrary.get_by_id(STARTING_ROOM_ID)
	if starting_card:
		_register_tile(starting_card)
		starting_tile_registered.emit(starting_card)
		_log("Your house begins with: %s" % starting_card.card_name)

	enter_build_phase()

func enter_build_phase() -> void:
	var excess_arcana: int = resources.get("arcana", 0)
	if excess_arcana > 0:
		var gained := int(excess_arcana * 0.5)
		if gained > 0:
			resources["insight"] = resources.get("insight", 0) + gained
			_log("Arcana fades — gained %d Insight." % gained)
		resources["arcana"] = 0

	DeckManager.discard_hand()
	current_phase = Phase.BUILD
	resources_changed.emit()
	phase_changed.emit(current_phase)
	_log("=== Build Phase ===")

func select_draft_tile(card: CardData) -> void:
	pending_tile = card
	tile_draft_selected.emit(card)

# Returns true if affordable; deducts cost and registers tile but does NOT
# start the living phase — the caller handles sequencing.
func confirm_placement(card: CardData) -> bool:
	for resource in card.cost:
		if resources.get(resource, 0) < card.cost[resource]:
			_log("Can't afford %s!" % card.card_name)
			return false
	for resource in card.cost:
		resources[resource] = resources.get(resource, 0) - card.cost[resource]
	_register_tile(card)
	pending_tile = null
	resources_changed.emit()
	_log("Placed: %s" % card.card_name)
	return true

func _register_tile(card: CardData) -> void:
	tiles_placed.append(card)
	DeckManager.add_card(card)

func enter_living_phase() -> void:
	pending_tile = null
	current_phase = Phase.LIVING
	turn_number = 0
	phase_changed.emit(current_phase)
	_log("=== Living Phase ===")
	_begin_turn()

func _begin_turn() -> void:
	turn_number += 1
	_log("-- Turn %d --" % turn_number)

	for tile in tiles_placed:
		for resource in tile.produces:
			resources[resource] = resources.get(resource, 0) + tile.produces[resource]

	resources_changed.emit()
	DeckManager.draw_hand()

	for tile in tiles_placed:
		if randf() < tile.threat_chance:
			active_threats.append(tile.id)
			threat_spawned.emit(tile.id)
			_log("Threat spawned from: %s!" % tile.card_name)

func end_turn() -> void:
	DeckManager.discard_hand()
	_begin_turn()

func play_card(card: CardData) -> void:
	match card.card_effect:
		"draw_card":
			DeckManager.draw_hand()
			_log("%s: drew extra cards." % card.card_name)
		"restore_hp":
			hp = min(hp + 2, MAX_HP)
			_log("%s: restored 2 HP." % card.card_name)
		"gain_gold":
			resources["gold"] = resources.get("gold", 0) + 2
			_log("%s: gained 2 Gold." % card.card_name)
		"gain_insight":
			resources["insight"] = resources.get("insight", 0) + 1
			_log("%s: gained 1 Insight." % card.card_name)
		"arcane_surge":
			resources["arcana"] = resources.get("arcana", 0) + 2
			_log("%s: Arcana surges." % card.card_name)
		"arcane_drain":
			resources["arcana"] = resources.get("arcana", 0) + 1
			hp -= 1
			_log("%s: darkness takes its toll (-1 HP)." % card.card_name)
		_:
			if card.card_effect != "":
				_log("%s: played." % card.card_name)
	resources_changed.emit()
	DeckManager.play_card(card)

func resolve_threat(tile_id: String) -> void:
	if not active_threats.has(tile_id):
		return
	active_threats.erase(tile_id)
	threat_resolved.emit(tile_id)
	if resources.get("arcana", 0) >= 1:
		resources["arcana"] = resources.get("arcana", 0) - 1
		_log("Threat resolved at %s (spent 1 Arcana)." % tile_id)
	else:
		hp -= 2
		_log("Threat at %s uncontrolled — took 2 damage!" % tile_id)
	if hp <= 0:
		run_ended.emit(false)
	resources_changed.emit()

func can_afford(card: CardData) -> bool:
	for resource in card.cost:
		if resources.get(resource, 0) < card.cost[resource]:
			return false
	return true

func _log(msg: String) -> void:
	log_message.emit(msg)
