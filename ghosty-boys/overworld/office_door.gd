extends Area2D

@export var destination_scene: String

var has_triggered: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	print("Something entered OfficeDoor: ", body.name)
	if not body.is_in_group("player"):
		return
	if has_triggered:
		return

	has_triggered = true
	SceneTransition.fade_to_scene(destination_scene)


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		has_triggered = false
