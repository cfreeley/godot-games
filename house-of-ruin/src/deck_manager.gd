extends Node

signal hand_updated()
signal deck_changed()

const HAND_SIZE := 5

var deck: Array[CardData] = []
var hand: Array[CardData] = []
var discard: Array[CardData] = []

func add_card(card: CardData) -> void:
	discard.append(card)
	deck_changed.emit()

func draw_hand() -> void:
	hand.clear()
	for i in range(HAND_SIZE):
		if deck.is_empty():
			if discard.is_empty():
				break
			_shuffle_discard_to_deck()
		if not deck.is_empty():
			hand.append(deck.pop_back())
	hand_updated.emit()

func play_card(card: CardData) -> void:
	hand.erase(card)
	discard.append(card)
	hand_updated.emit()

func discard_hand() -> void:
	discard.append_array(hand)
	hand.clear()
	hand_updated.emit()

func _shuffle_discard_to_deck() -> void:
	deck = discard.duplicate()
	deck.shuffle()
	discard.clear()
	deck_changed.emit()

func get_deck_size() -> int:
	return deck.size() + discard.size()
