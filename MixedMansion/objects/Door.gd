extends "res://objects/Furniture.gd"

export(int) var door_id = 0

func enter():
	Game.manor.enter_door(door_id)
