extends Area2D

var velocity = Vector2.ZERO

func _physics_process(delta):
  position += velocity

func _on_body_entered(body):
  if (body.name == 'Hero'):
    return
  velocity = Vector2.ZERO
  $Explosion.emitting = false
  queue_free()
