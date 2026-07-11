extends Node

@export var bpm : float = 160.0

var current_measure : int = 0
var current_total_beat : int = 0
var current_loop : int = 0
var loop_length : int = 0
var current_measure_beat = 0

var _last_raw_beat : float = 0.0

@onready var audio_player = $AudioStreamPlayer

signal measure_hit
signal beat_hit


func _ready() -> void:
	loop_length = _get_song_length_in_beats(audio_player.stream)
	print("Song is " + str(loop_length) + " beats long!")
	audio_player.play()


func _process(_delta: float) -> void:
	var raw_beat := _get_raw_beat()

	if raw_beat < _last_raw_beat - (loop_length * 0.5):
		current_loop += 1
	_last_raw_beat = raw_beat

	var last_total_beat := current_total_beat
	current_total_beat = floori(get_song_position())
	current_measure = current_total_beat / 4
	current_measure_beat = current_total_beat % 4

	if current_total_beat != last_total_beat:
		print(str(current_total_beat) + ", (" + str(current_measure) + ": " + str(current_measure_beat) + ")")
		beat_hit.emit()
		if current_measure_beat == 0:
			measure_hit.emit()
			

func _get_raw_beat() -> float:
	var t = audio_player.get_playback_position() \
		+ AudioServer.get_time_since_last_mix() \
		- AudioServer.get_output_latency()
	t = maxf(t, 0.0)
	return t / (60.0 / bpm)


func get_song_position() -> float:
	return _get_raw_beat() + (current_loop * loop_length)


func _get_song_length_in_beats(stream : AudioStream) -> int:
	var beats := stream.get_length() / (60.0 / bpm)
	var rounded := roundi(beats)
	if absf(beats - rounded) > 0.05:
		push_warning("Loop isn't a whole number of beats (%.3f) — trim the audio file." % beats)
	return rounded
