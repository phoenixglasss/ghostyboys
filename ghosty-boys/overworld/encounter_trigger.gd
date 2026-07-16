extends Area2D
class_name EncounterTrigger

@export var encounter: EncounterData
@export var trigger_id: String
@export var wander_radius: float = 40.0
@export var wander_speed: float = 30.0

var has_triggered: bool = false
var home_position: Vector2
var wander_target: Vector2


func _ready() -> void:
	if GameState.is_trigger_cleared(trigger_id):
		queue_free()
		return
	
	body_entered.connect(_on_body_entered)
	home_position = position
	wander_target = position
	$WanderTimer.timeout.connect(_pick_new_wander_target)
	_pick_new_wander_target()
	

func _process(delta: float) -> void:
	if has_triggered:
		return
	position = position.move_toward(wander_target, wander_speed * delta)

func _pick_new_wander_target() -> void:
	var offset := Vector2(randf_range(-wander_radius, wander_radius), randf_range(-wander_radius, wander_radius))
	wander_target = home_position + offset


func _on_body_entered(body: Node2D) -> void:
	if has_triggered:
		return
	if not body.is_in_group("player"):
		return

	has_triggered = true
	SceneTransition.go_to_battle(encounter)
	GameState.pending_trigger_id = trigger_id
	SceneTransition.go_to_battle(encounter)
