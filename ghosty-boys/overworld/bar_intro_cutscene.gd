extends Node

@export var bartender_interactable: Interactable
@export var patron_1_display: NPCDisplay
@export var patron_2_display: NPCDisplay
@export var bartender_display: NPCDisplay
@export var bartender_repeat_line: DialogueConversation
@export var mel_jackal_reveal_line: DialogueConversation
@export var tutorial_encounter: EncounterData

func _ready() -> void:
	if GameState.tutorial_fight_won:
		return
	bartender_interactable.interaction_conversation_finished.connect(_on_bartender_done)
	
func _on_bartender_done() -> void:
	await get_tree().create_timer(0.6).timeout
	
	# to do. swap for explodey animation.
	patron_1_display.visible = false
	await get_tree().create_timer(0.6).timeout
	
	# also swap for explodey
	patron_2_display.visible = false
	await get_tree().create_timer(0.6).timeout
	
	DialogueBox.start_conversation(bartender_repeat_line)
	await DialogueBox.conversation_finished
	
	# swap swap swap
	bartender_display.visible = false
	await get_tree().create_timer(0.6).timeout
	
	DialogueBox.start_conversation(mel_jackal_reveal_line)
	await DialogueBox.conversation_finished
	
	SceneTransition.go_to_battle(tutorial_encounter)
	
	
	
	
	
	
