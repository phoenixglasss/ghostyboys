extends CharacterBody2D

@export var speed: float = 120

var facing_direction: Vector2 = Vector2.DOWN

func _physics_process(_delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * speed
	move_and_slide()

	if input_dir != Vector2.ZERO:
		facing_direction = input_dir
