extends Node

var PlayerStats := {
  'STR': 0,
  'AGI': 0,
  'ARC': 0,
  'HP': 4
}

var Map := {
  'PlayerCell': { }
}

signal room_enter()
signal room_investigate()
signal room_move(dir : String)
