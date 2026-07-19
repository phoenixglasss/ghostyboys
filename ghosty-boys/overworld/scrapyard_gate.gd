extends Area2D

@export var destination_scene: String
@export var banter_conversation: DialogueConversation
@export var not_ready_conversation: DialogueConversation
@export var gate_encounter: EncounterData

var has_triggered: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if has_triggered:
		return

	if GameState.scrapyard_gate_won:
		has_triggered = true
		SceneTransition.fade_to_scene(destination_scene)
	elif GameState.dover_intro_played and not GameState.dave_banter_played:
		has_triggered = true
		DialogueBox.start_conversation(banter_conversation)
		await DialogueBox.conversation_finished
		GameState.dave_banter_played = true
		SceneTransition.go_to_battle(gate_encounter)
	elif GameState.dover_intro_played and GameState.dave_banter_played:
		has_triggered = true
		SceneTransition.go_to_battle(gate_encounter)
	else:
		if not DialogueBox.visible:
			DialogueBox.start_conversation(not_ready_conversation)


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		has_triggered = false
