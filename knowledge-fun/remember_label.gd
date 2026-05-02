extends Label


# Called when the node enters the scene tree for the first time.
var tween
func _ready():
  fade_in()

func fade_in():
  tween = get_tree().create_tween()
  tween.tween_property(self, "modulate", Color.TRANSPARENT, 1.0).set_trans(Tween.TRANS_SINE)
  tween.tween_callback(fade_out)

func fade_out():
  tween = get_tree().create_tween()
  tween.tween_property(self, "modulate", Color.WHITE, 1.0).set_trans(Tween.TRANS_SINE)
  tween.tween_callback(fade_in)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
  pass
