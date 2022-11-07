extends TextureButton

var mute_texture
var unmute_texture
var local_ismuted

func _ready():
	mute_texture = preload("res://images/mute.png")
	unmute_texture = preload("res://images/sound.png")

func _process(_delta):
	if (local_ismuted == SoundControl.is_muted):
		return
	
	local_ismuted = SoundControl.is_muted
	if (SoundControl.is_muted):
		texture_normal = mute_texture
	else:
		texture_normal = unmute_texture

func _on_MuteButton_pressed():
	SoundControl.is_muted = !SoundControl.is_muted
	var bus_idx = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(bus_idx, SoundControl.is_muted)
