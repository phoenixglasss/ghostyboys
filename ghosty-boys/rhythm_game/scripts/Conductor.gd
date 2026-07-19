extends Node
class_name Conductor

@export var bpm : float = 160.0

var current_measure : int = 0
var current_total_beat : int = 0
var current_loop : int = 0
var loop_length : int = 0
var current_measure_beat = 0
var _last_raw_beat : float = 0.0
var raw_beat : float = 0.0

@export var bgm_file : AudioStream = preload("res://rhythm_game/test_files/audio/click_8mm.ogg")

@onready var audio_player : AudioStreamPlayer = $BackgroundMusicPlayer
@onready var action_player : AudioStreamPlayer = $ActionMusicPlayer

@export var battle_manager : BattleManager
var chart_layer : CanvasLayer

var chart_display : PackedScene = preload("res://rhythm_game/scenes/chart_display.tscn")

signal chart_completed(score : float)

signal measure_hit
signal beat_hit

@onready var finale_player : AudioStreamPlayer = $FinalePlayer

const FINALE_PLAYER_SLOT := Vector2(0, 0)
const FINALE_ENEMY_SLOT := Vector2(0, 72)

@export var finale_max_health : float = 100.0
@export var finale_damage : float = 2.0   # d
@export var finale_heal : float = 3.0      # h
var finale_health : float = 0.0

signal finale_health_changed(current : float, max_health : float)
signal finale_player_died


func _ready() -> void:
	loop_length = _get_song_length_in_beats(audio_player.stream)
	# print("Song is " + str(loop_length) + " beats long!")
	# audio_player.stream = bgm_file
	# audio_player.play()
	# gotta hit on the first beat, too
	beat_hit.emit()
	measure_hit.emit()



func _process(_delta: float) -> void:
	if (battle_manager and !chart_layer): 
		chart_layer = battle_manager.get_node("ChartLayer")
	elif (!chart_layer):
		chart_layer = $"../ChartLayer"
		
	raw_beat = _get_raw_beat()

	if raw_beat < _last_raw_beat - (loop_length * 0.5):
		current_loop += 1
	_last_raw_beat = raw_beat

	var last_total_beat := current_total_beat
	current_total_beat = floori(get_song_position())
	current_measure = current_total_beat / 4
	current_measure_beat = current_total_beat % 4

	if current_total_beat != last_total_beat:
		# print(str(current_total_beat) + ", (" + str(current_measure) + ": " + str(current_measure_beat) + ")")
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
	
func play_chart(chart_to_play : Chart) -> void:
	var new_chart_display : ChartDisplay = chart_display.instantiate()
	new_chart_display.my_chart = chart_to_play
	new_chart_display.position.y = 102
	chart_layer.add_child(new_chart_display)
	new_chart_display.z_index += 100
	new_chart_display.chart_completed.connect(_chart_completed)

func _chart_completed(score : float) -> void:
	chart_completed.emit(score)
	
func play_finale(chart : Chart) -> void:
	if !chart_layer:
		chart_layer = $"../ChartLayer"  # or battle_manager path, match your _process logic

	# warm the stream so the first .play() has no load hitch
	finale_player.stream = chart.audio

	# one shared, bar-aligned start for BOTH displays
	var earliest : float = get_song_position() + 1.5
	var sb : float = ceil(earliest / 4.0) * 4.0

	var p : ChartDisplay = chart_display.instantiate()
	p.my_chart = chart
	p.side = 0
	p.plays_audio = true
	p.is_finale = true          # routes audio to finale_player + ducks BGM
	p.start_beat_override = sb
	p.position = FINALE_PLAYER_SLOT
	chart_layer.add_child(p)
	p.z_index += 100
	p.chart_completed.connect(_chart_completed)   # only the player scores
	
	finale_health = finale_max_health
	p.note_resolved.connect(_on_finale_note_resolved)
	finale_health_changed.emit(finale_health, finale_max_health)

	var e : ChartDisplay = chart_display.instantiate()
	e.my_chart = chart
	e.side = 1
	e.autoplay = true
	e.plays_audio = false
	e.start_beat_override = sb
	e.position = FINALE_ENEMY_SLOT
	chart_layer.add_child(e)
	e.z_index += 100

func _on_finale_note_resolved(rating : int) -> void:
	match rating:
		0:
			finale_health -= finale_damage
		2:
			finale_health += finale_heal
		3:
			finale_health += finale_heal * 2.0
		# rating 1 falls through = no change
	finale_health = clampf(finale_health, 0.0, finale_max_health)
	finale_health_changed.emit(finale_health, finale_max_health)
	if finale_health <= 0.0:
		finale_player_died.emit()
