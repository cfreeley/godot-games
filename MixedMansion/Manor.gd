extends Node2D

var Foyer = preload("res://rooms/Foyer.tscn")
export(Array, PackedScene) var room_types = []
var rooms = []
var rooms_by_door = {}
var last_door

func generate_mansion():
	var foyer = Foyer.instance()
	$Rooms.add_child(foyer)
	rooms.push_back(foyer)
	
	for door in get_tree().get_nodes_in_group("door"):
		var id = door.door_id
		if (id % 2 == 0): continue
		var new_room = room_types[0].instance()
		new_room.rotation = door.rotation + PI
		var offset = new_room.get_node("ConnectPos").position.rotated(door.rotation + PI)
		new_room.position = door.get_node("ConnectPos").global_position - offset
		new_room.get_node("Door").door_id = id * -1
		rooms_by_door[id] = new_room
		$Rooms.add_child(new_room)
		rooms.push_back(new_room)

func _ready():
	Game.manor = self
	generate_mansion()
	move_player(rooms[0])
	
func move_player(room, door = null):
	$Player.position = room.get_node("PlayerSpawn").global_position
	if (last_door):
		last_door.get_node("Body/Sprite").modulate = Color.white
	if (door):
		door.get_node("Body/Sprite").modulate = Color.white * 2
		last_door = door

func enter_door(door_id):
	for room in rooms:
		for child in room.get_children():
			if ("door_id" in child and child.door_id == door_id * -1):
				move_player(room, child)
				return
	print("Door doesn't seem to budge.")
	


