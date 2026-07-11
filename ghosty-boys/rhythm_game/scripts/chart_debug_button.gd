extends Button

@export var chart : Chart
@export var conductor : Conductor

func _ready() -> void:
	pressed.connect(_press)

func _press() -> void:
	conductor.play_chart(chart)
