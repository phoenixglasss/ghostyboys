extends Node2D

var lane : int = 0

func _ready() -> void:
	match lane:
		1:
			$Sprite2D.rotation_degrees = -90
		2:
			$Sprite2D.rotation_degrees = 90
		3:
			$Sprite2D.rotation_degrees = 180
