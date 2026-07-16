extends Node2D
class_name EnemyDisplay

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var placeholder: Sprite2D = $Placeholder


func setup(enemy_data: EnemyData) -> void:
	if enemy_data.sprite_frames:
		placeholder.visible = true
		sprite.visible = true
		sprite.sprite_frames = enemy_data.sprite_frames
		sprite.play("idle")
	else:
		placeholder.visible = true
		sprite.visible = true

func set_highlighted(highlighted: bool) -> void:
	modulate = Color(1.3, 1.3, 1.3) if highlighted else Color.WHITE
