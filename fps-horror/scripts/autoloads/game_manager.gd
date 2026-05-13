extends Node

## GameManager — Autoload singleton
## Manages global game state, player status, and game flow.
## All systems should read/write state through here rather than each other.

signal state_changed(new_state: State)
signal enemy_alert_changed(level: float)

enum State {
	EXPLORING,  ## Player is moving freely through the environment
	HIDING,     ## Player is inside a hiding spot
	CAUGHT,     ## Enemy has caught the player — triggers game over flow
	CUTSCENE,   ## Non-interactive moment (intro, ending, etc.)
	PAUSED,     ## Game is paused
	GAME_OVER,  ## End state
}

var current_state: State = State.EXPLORING

## 0.0 = fully calm, 1.0 = enemy is actively hunting
var enemy_alert_level: float = 0.0

func _ready() -> void:
	# Always process so pause state can still be received
	process_mode = Node.PROCESS_MODE_ALWAYS


# ---------------------------------------------------------------------------
# State Management
# ---------------------------------------------------------------------------

func change_state(new_state: State) -> void:
	if current_state == new_state:
		return
	current_state = new_state
	emit_signal("state_changed", new_state)
	_on_state_entered(new_state)


func _on_state_entered(state: State) -> void:
	match state:
		State.EXPLORING:
			get_tree().paused = false
		State.HIDING:
			pass  # Player movement is locked by the player script
		State.CAUGHT:
			_trigger_game_over()
		State.PAUSED:
			get_tree().paused = true
		State.GAME_OVER:
			pass  # TODO: load game-over screen


func _trigger_game_over() -> void:
	await get_tree().create_timer(1.5).timeout
	change_state(State.GAME_OVER)


# ---------------------------------------------------------------------------
# Convenience helpers
# ---------------------------------------------------------------------------

func is_hiding() -> bool:
	return current_state == State.HIDING


func is_exploring() -> bool:
	return current_state == State.EXPLORING


func pause_game() -> void:
	change_state(State.PAUSED)


func resume_game() -> void:
	change_state(State.EXPLORING)


# ---------------------------------------------------------------------------
# Enemy Alert
# ---------------------------------------------------------------------------

func set_enemy_alert(level: float) -> void:
	enemy_alert_level = clamp(level, 0.0, 1.0)
	emit_signal("enemy_alert_changed", enemy_alert_level)


func raise_alert(amount: float) -> void:
	set_enemy_alert(enemy_alert_level + amount)


func lower_alert(amount: float) -> void:
	set_enemy_alert(enemy_alert_level - amount)
