extends CanvasLayer

## HUD — Minimal heads-up display for the horror game.
## Registered in the "hud" group so the Player can find it without a hard reference.
##
## Prompts:
##   InteractionPrompt — shown when looking at an interactable (E key)
##   HeldPrompt        — shown while holding an item (LMB to drop)
##   ReadingPanel      — shown when holding a readable item (note, paper, sign)

@onready var crosshair: Label           = $Control/Center/Crosshair
@onready var interaction_prompt: Label  = $Control/InteractionPrompt
@onready var held_prompt: Label         = $Control/HeldPrompt
@onready var reading_panel: Panel       = $Control/ReadingPanel
@onready var reading_text: Label        = $Control/ReadingPanel/Margin/VBox/ReadingText


func _ready() -> void:
	add_to_group("hud")  # Explicit registration — .tscn group tags are unreliable in 4.6
	hide_interaction_prompt()
	hide_held_prompt()
	hide_reading_text()


# ---------------------------------------------------------------------------
# Interaction prompt  (looking at something interactive)
# ---------------------------------------------------------------------------

func show_interaction_prompt(text: String) -> void:
	interaction_prompt.text = text
	interaction_prompt.visible = true


func hide_interaction_prompt() -> void:
	interaction_prompt.visible = false


# ---------------------------------------------------------------------------
# Held item prompt  (currently holding something)
# ---------------------------------------------------------------------------

func show_held_prompt(item_name: String) -> void:
	held_prompt.text = "[LMB]  Put down  %s" % item_name
	held_prompt.visible = true


func hide_held_prompt() -> void:
	held_prompt.visible = false


# ---------------------------------------------------------------------------
# Reading panel  (text on held item is readable)
# ---------------------------------------------------------------------------

func show_reading_text(text: String) -> void:
	reading_text.text = text
	reading_panel.visible = true


func hide_reading_text() -> void:
	reading_panel.visible = false


# ---------------------------------------------------------------------------
# Crosshair
# ---------------------------------------------------------------------------

func set_crosshair_visible(value: bool) -> void:
	crosshair.visible = value
