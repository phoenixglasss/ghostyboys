extends Area2D
class_name ExitDoor

@export var blocked_conversation: DialogueConversation
@export var destination_scene: String

@onready var physical_block: CollisionShape2D = $StaticBody2D/CollisionShape2D

var has_triggered: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_update_lock_state()
	
func _update_lock_state() -> void:
	physical_block.disabled = GameState.bar_unlocked
	
func unlock() -> void:
	GameState.bar_unlocked = true
	_update_lock_state()
	
	
func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
		
	if GameState.bar_unlocked:
		if has_triggered:
			return
		has_triggered = true
		SceneTransition.fade_to_scene(destination_scene)
	else:
		if not DialogueBox.visible:
			DialogueBox.start_conversation(blocked_conversation)
		
func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		has_triggered = false
