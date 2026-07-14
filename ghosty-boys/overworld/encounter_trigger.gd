extends Area2D
class_name EncounterTrigger

@export var encounter: EncounterData

var has_triggered: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	

func _on_body_entered(body: Node2D) -> void:
	if has_triggered:
		return
	if not body.is_in_group("player"):
		return

	has_triggered = true
	SceneTransition.go_to_battle(encounter)
