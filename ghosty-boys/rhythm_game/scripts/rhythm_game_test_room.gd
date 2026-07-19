extends Node2D

@onready var conductor : Conductor = $Conductor

@export var bgm : BGM

func _ready() -> void:
	if conductor:
		conductor.bpm = bgm.bpm
		conductor.audio_player.stream = bgm.audio
		conductor.audio_player.play()
