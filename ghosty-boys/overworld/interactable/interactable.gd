extends Area2D
class_name Interactable

@export var conversations: Array[DialogueConversation]
@export var interactable_id: String

var player_in_range: Node2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = body
		
func _on_body_exited(body: Node2D) -> void:
	if body == player_in_range:
		player_in_range = null

func _unhandled_input(event: InputEvent) -> void:
	if DialogueBox.visible:
		return
	if not player_in_range:
		return
	if not event.is_action_pressed("interact"):
		return
		
	var facing_raw = player_in_range.get("facing_direction")
	if facing_raw == null:
		return
		
	var facing: Vector2 = Vector2(facing_raw)
	var to_npc: Vector2 = (global_position - player_in_range.global_position).normalized()
	if to_npc.dot(facing) > 0.5:
		return
		
	var conversation := _get_current_conversation()
	if not conversation:
		return
		
	get_viewport().set_input_as_handled()
	DialogueBox.start_conversation(conversation)
	GameState.increment_interaction_count(interactable_id)

func _get_current_conversation() -> DialogueConversation:
	if conversations.is_empty():
		return null
	var count : int = GameState.get_interaction_count(interactable_id)
	var index: int = min(count, conversations.size() - 1)
	return conversations[index]
