extends AnimatedSprite2D

func _ready() -> void:
	animation_finished.connect(_reset)
	play("none")

func _reset():
	if animation != "none":
		play("none")
