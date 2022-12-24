extends PathFollow2D

var health = 3
var reward = 25

var health_colors = [Color.green, Color.orange, Color.red]

func _ready():
	change_health(0)

func _process(delta):
	offset += delta * 100

func change_health(val):
	health += val
	if (health <= 0):
		get_parent().owner.money += reward
		get_parent().owner.kills += 1
		queue_free()
	else:
		# $Area2D/Sprite.modulate = health_colors[ health_colors.size() - health ] * 1.25
		$Area2D/Sprite.modulate.a = 1

func _on_Area2D_area_entered(area):
	if (area.is_in_group('bullet')):
		change_health(-area.damage)
		area.queue_free()
