extends Node


func _ready() -> void:
	if not GameState.intro_dialogue_played:
		DialogueBox.start_conversation(load("res://dialogue/bar/daisy_arrival.tres"))
		GameState.intro_dialogue_played = true
	elif GameState.tutorial_fight_won and not GameState.closing_dialogue_played:
		DialogueBox.start_conversation(load("res://dialogue/bar/mel_jackal_closing.tres"))
		GameState.closing_dialogue_played = true
