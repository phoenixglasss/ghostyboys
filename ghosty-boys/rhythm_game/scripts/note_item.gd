extends Area2D
class_name NoteItem

var lane : int = 0
var rating : Rating = Rating.MISS

enum Rating {
	MISS, OKAY, GOOD, PERFECT
}

func _process(delta: float) -> void:
	$Label.text = str(rating)

func _ready() -> void:
	match lane:
		1:
			$Sprite2D.rotation_degrees = -90
		2:
			$Sprite2D.rotation_degrees = 90
		3:
			$Sprite2D.rotation_degrees = 180
