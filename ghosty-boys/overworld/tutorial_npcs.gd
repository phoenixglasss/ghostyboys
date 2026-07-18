extends Node

func _ready() -> void:
	if GameState.tutorial_fight_won:
		queue_free()
