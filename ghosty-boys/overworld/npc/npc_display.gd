extends Node2D
class_name NPCDisplay

@export var npc_data: NPCData
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D



func _ready() -> void:
	if npc_data:
		_apply_data()

func _apply_data() -> void:
	sprite.sprite_frames = npc_data.sprite_frames
	if sprite.sprite_frames.has_animation("idle_down"):
		sprite.play("idle_down")
	elif sprite.sprite_frames.has_animation("walk_down"):
		sprite.play("walk_down")
		sprite.stop()
		sprite.frame = 0
