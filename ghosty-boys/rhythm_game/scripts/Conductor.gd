extends Node

@export var bpm : float = 160.0

var current_beat : int = 0
var current_measure : int = 0

@onready var audio_player = $AudioStreamPlayer



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	audio_player.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print(_get_song_position())

func _get_song_position() -> float:
	var t = audio_player.get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency()
	var beat_length = 60 / bpm
	var song_pos = t / beat_length
	return song_pos
