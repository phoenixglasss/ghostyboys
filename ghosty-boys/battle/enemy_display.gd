extends Node2D
class_name EnemyDisplay

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var conductor : Conductor
var bounce_curve : Curve = preload("res://rhythm_game/bounce.tres")


func setup(enemy_data: EnemyData) -> void:
	if enemy_data.sprite_frames:
		sprite.sprite_frames = enemy_data.sprite_frames
	sprite.play("idle")
	
	var current_texture: Texture2D = sprite.sprite_frames.get_frame_texture(sprite.animation, 0)
	var texture_height: float = current_texture.get_size().y
	var current_height: float = texture_height * scale.y
	sprite.offset.y -= current_height
	sprite.position.y += current_height

func _process(delta: float) -> void:
	if conductor:
		var bounded_beat : float = fmod(conductor.raw_beat,2.0)
		var bounce_scale_mod = bounce_curve.sample_baked(bounded_beat)
		sprite.scale.y = 1 + bounce_scale_mod * 0.05

func set_highlighted(highlighted: bool) -> void:
	modulate = Color(1.3, 1.3, 1.3) if highlighted else Color.WHITE
