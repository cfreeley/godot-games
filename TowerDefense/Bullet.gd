extends Node2D

export var damage = 100

var speed = 600
var direction

func _physics_process(delta):
	if (direction):
		position += direction * speed * delta
