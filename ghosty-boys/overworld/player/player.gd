extends CharacterBody2D

@export var speed: float = 120
const TRAIL_SPACING: float = 4.0
var position_history: Array[Vector2] = []
var facing_direction: Vector2i = Vector2i.DOWN
var is_moving: bool = false

func _physics_process(_delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * speed
	move_and_slide()
	is_moving = velocity.length() > 0
	_record_trail_point()

	# ensures facing_direction is always a cardinal direction, for animation purposes
	if Input.is_action_just_pressed("move_left"):
		facing_direction = Vector2i.LEFT
		$AnimatedSprite2D.play("walk_left")
	if Input.is_action_just_pressed("move_right"):
		facing_direction = Vector2i.RIGHT
		$AnimatedSprite2D.play("walk_right")
	if Input.is_action_just_pressed("move_up"):
		facing_direction = Vector2i.UP
		$AnimatedSprite2D.play("walk_up")
	if Input.is_action_just_pressed("move_down"):
		facing_direction = Vector2i.DOWN
		$AnimatedSprite2D.play("walk_down")
	
	if velocity.length() == 0:
		$AnimatedSprite2D.frame = 0
		$AnimatedSprite2D.stop()
	
func _record_trail_point() -> void:
	if position_history.is_empty() or global_position.distance_to(position_history[-1]) >= TRAIL_SPACING:
		position_history.append(global_position)
		if position_history.size() > 300:
			position_history.pop_front()
