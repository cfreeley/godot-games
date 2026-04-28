extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
  pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
  pass

func _unhandled_input(event):
  if event is InputEventKey and event.pressed and event.keycode >= Key.KEY_A and event.keycode <= Key.KEY_Z:
    text += OS.get_keycode_string(event.physical_keycode)
