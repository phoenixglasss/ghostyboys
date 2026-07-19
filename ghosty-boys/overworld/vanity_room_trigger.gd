extends Area2D

@export var intro_conversation: DialogueConversation
@export var boss_encounter: EncounterData

var has_triggered: bool = false


func _ready() -> void:
	if GameState.final_boss_defeated:
		queue_free()
		return
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if has_triggered:
		return
	has_triggered = true

	if not GameState.boss_intro_played:
		GameState.boss_intro_played = true
		DialogueBox.start_conversation(intro_conversation)
		await DialogueBox.conversation_finished

	SceneTransition.go_to_battle(boss_encounter)


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		has_triggered = false
