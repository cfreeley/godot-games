extends Node2D

signal player_dead

func _ready():
  spawn_player()

func spawn_player():
  $Hero.position = $PlayerSpawn.position

func _on_player_dead():
  spawn_player()
