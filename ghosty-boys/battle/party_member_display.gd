extends Node2D
class_name PartyMemberDisplay

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var conductor : Conductor

var bounce_curve : Curve = preload("res://rhythm_game/bounce.tres")

func setup(member: PartyMember) -> void:
	if member.sprite_frames:
		sprite.sprite_frames = member.sprite_frames
		if sprite.sprite_frames.has_animation("battle_enter"):
			sprite.play("battle_enter")
		else:
			sprite.play("walk_down")
	
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
