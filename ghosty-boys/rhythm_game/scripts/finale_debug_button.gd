extends Button

@export var chart : Chart
@export var bgm : BGM
@export var conductor : Conductor

func _ready() -> void:
	pressed.connect(_press)

func _press():
	conductor.play_finale(chart)
