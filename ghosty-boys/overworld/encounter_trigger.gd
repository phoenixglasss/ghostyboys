extends Area2D
class_name EncounterTrigger

@export var encounter: EncounterData
@export var display_data: EnemyData
@export var trigger_id: String
@export var wander_radius: float = 40.0
@export var wander_speed: float = 30.0

var has_triggered: bool = false
var home_position: Vector2
var wander_target: Vector2

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	if GameState.is_trigger_cleared(trigger_id):
		queue_free()
		return
		
	if display_data and display_data.overworld_sprite_frames:
		sprite.sprite_frames = display_data.overworld_sprite_frames
	
	body_entered.connect(_on_body_entered)
	home_position = position
	wander_target = position
	$WanderTimer.timeout.connect(_pick_new_wander_target)
	_pick_new_wander_target()
	

func _process(delta: float) -> void:
	if has_triggered:
		return
		
	var old_position := position
	position = position.move_toward(wander_target, wander_speed * delta)
	var moved: Vector2 = position - old_position
	
	if moved.length() > 0.1:
		_play_walk_animation(moved)
	else:
		_play_idle_animation()
		
func _play_walk_animation(direction: Vector2) -> void:
	if not sprite.sprite_frames:
		return
	var anim_name := _animation_name_for(direction, "walk_")
	if sprite.sprite_frames.has_animation(anim_name):
		sprite.play(anim_name)
		
func _play_idle_animation() -> void:
	if not sprite.sprite_frames:
		return
	if sprite.sprite_frames.has_animation("idle_down"):
		sprite.play("idle_down")
		sprite.stop()
		sprite.frame = 0

func _animation_name_for(direction: Vector2, prefix: String) -> String:
	if abs(direction.x) > abs(direction.y):
		return prefix + ("right" if direction.x > 0 else "left")
	return prefix + ("down" if direction.y > 0 else "up")

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
