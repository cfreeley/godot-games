class_name CardData
extends Resource

@export var id: String = ""
@export var card_name: String = ""
@export var rarity: String = "common"
@export var cost: Dictionary = {}      # placement cost  e.g. {"gold": 2}
@export var produces: Dictionary = {}  # per-turn generation e.g. {"gold": 1, "arcana": 2}
@export var threat_chance: float = 0.0
@export var card_effect: String = ""   # exceptional drawn effect (blank = no extra effect)
@export var description: String = ""
