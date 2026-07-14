extends Node2D
class_name PartyMemberDisplay

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func setup(member: PartyMember) -> void:
	if member.sprite_frames:
		sprite.sprite_frames = member.sprite_frames
		if sprite.sprite_frames.has_animation("battle_enter"):
			sprite.play("battle_enter")
		else:
			sprite.play("walk_down")
