extends Node

@export var bartender_interactable: Interactable
@export var patron_1_display: NPCDisplay
@export var patron_2_display: NPCDisplay
@export var bartender_display: NPCDisplay
@export var bartender_repeat_line: DialogueConversation
@export var mel_jackal_reveal_line: DialogueConversation
@export var tutorial_encounter: EncounterData
@export var mel_display: NPCDisplay
@export var jackal_display: NPCDisplay

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
	
	var player := get_tree().get_first_node_in_group("player")
	if player:
		var mel_target: Vector2 = player.global_position + Vector2(-26, -8)
		var jackal_target: Vector2 = player.global_position + Vector2(-16, 8)
		print("Mel: ", mel_display.global_position, " -> ", mel_target)
		print("Jackal: ", jackal_display.global_position, " -> ", jackal_target)
		await _walk_npcs_to([mel_display, jackal_display], [mel_target, jackal_target], 100.0)
	
	DialogueBox.start_conversation(mel_jackal_reveal_line)
	await DialogueBox.conversation_finished
	SceneTransition.go_to_battle(tutorial_encounter)
	
func _walk_npcs_to(displays: Array, targets: Array, speed: float) -> void:
	var all_arrived := false
	while not all_arrived:
		all_arrived = true
		for i in displays.size():
			var to_target: Vector2 = targets[i] - displays[i].global_position
			if to_target.length() > 2.0:
				displays[i].global_position = displays[i].global_position.move_toward(targets[i], speed * get_process_delta_time())
				displays[i].sprite.play(_walk_animation_for(to_target))
				all_arrived = false
		await get_tree().process_frame

	for display in displays:
		display.sprite.stop()
		display.sprite.frame = 0


func _walk_animation_for(direction: Vector2) -> String:
	if abs(direction.x) > abs(direction.y):
		return "walk_right" if direction.x > 0 else "walk_left"
	return "walk_down" if direction.y > 0 else "walk_up"
	
	
