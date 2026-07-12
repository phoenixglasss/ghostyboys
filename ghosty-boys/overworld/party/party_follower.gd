extends CharacterBody2D
class_name PartyFollower

@export var leader: Node2D
@export var follow_gap: int = 6

const TRAIL_SPACING: float = 4.0
var position_history: Array[Vector2] = []
var facing_direction: Vector2 = Vector2.DOWN
var is_moving: bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(_delta: float) -> void:
	if leader:
		var history: Array = leader.get("position_history")
		if history != null and not history.is_empty():
			var index: int = max(history.size() - 1 - follow_gap, 0)
			var target: Vector2 = history[index]
			var delta_move: Vector2 = target - global_position
			if delta_move.length() > 0.01:
				facing_direction = delta_move.normalized()
			global_position = history [index]
	
		is_moving = leader.get("is_moving")
		
	if is_moving:
		_play_movement_animation(facing_direction)
	else:
		sprite.frame = 0
		sprite.stop()
	
	_record_trail_point()

func _play_movement_animation(direction: Vector2) -> void:
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			sprite.play("walk_right")
		else:
			sprite.play("walk_left")
	elif direction.y > 0:
		sprite.play("walk_down")
	else:
		sprite.play("walk_up")


func _record_trail_point() -> void:
	if position_history.is_empty() or global_position.distance_to(position_history[-1]) >= TRAIL_SPACING:
		position_history.append(global_position)
		if position_history.size() > 300:
			position_history.pop_front()
