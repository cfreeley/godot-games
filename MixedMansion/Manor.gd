extends Node2D

export(Array, PackedScene) var room_types = []
var rooms

func _ready():
	rooms = $Rooms.get_children()
	Game.manor = self
	move_player(rooms[0])
	
func move_player(room):
	$Player.position = room.get_node("PlayerSpawn").global_position
	print($Player.position, room.name)

func enter_door(door_id):
	for room in rooms:
		for child in room.get_children():
			if ("door_id" in child and child.door_id == door_id * -1):
				move_player(room)
				return
	print("Door doesn't seem to budge.")
	


