extends Area2D

var explosion = preload("res://Explosion.tscn")

func _on_area_entered(area: Area2D):
  if (area.is_in_group("bullet")):
    var exp = explosion.instantiate()
    exp.set_power(2000)
    exp.position = position
    get_parent().add_child(exp)
    exp.emitting = true
    queue_free()

func _on_body_entered(body):
  if (body.name == 'Hero'):
    get_parent().emit_signal("player_dead")
