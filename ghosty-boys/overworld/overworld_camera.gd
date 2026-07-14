extends Camera2D

@export var player : CharacterBody2D
@export var camera_speed : float = 0.02


func _ready() -> void:
	position = player.position
	
func _process(delta: float) -> void:
	position = lerp(position, player.position, camera_speed)
