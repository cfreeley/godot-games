extends Node2D

@export var texture : Texture2D
@export var title : String
@export var diag : DialogueResource
@export var hp : int
@export var str : int
@export var dex : int

func _ready():
  $Sprite2D.texture = texture

func start():
  DialogueManager.show_dialogue_balloon(diag, "intro", )
