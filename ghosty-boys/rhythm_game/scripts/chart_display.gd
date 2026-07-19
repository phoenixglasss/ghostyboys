extends Node2D
class_name ChartDisplay

@export var conductor : Conductor
@export var lanes : Array[Node2D]
var notes : Array[NoteData]
var note_spacing : float = 64
@export var my_chart : Chart
@onready var hit_line : Node2D = $ChartContainer/HitLine
@onready var notes_container : Node2D = $ChartContainer/HitLine/Notes
@export var minimum_lead_beats : float = 2.5
var start_beat : float = 0.0
var audio_started : bool = false
var lane_data : Array[Array] = []
var note_item = preload("res://rhythm_game/scenes/note_item.tscn")

@export var side : int = 0
@export var autoplay : bool = false
@export var plays_audio : bool = true
@export var is_finale : bool = false
@export var start_beat_override : float = -1.0

signal note_resolved(rating : int)

var rating_total : int
var potential_total : int

signal chart_completed(chart_score : float)

func _ready() -> void:
	if !conductor:
		conductor = get_tree().get_first_node_in_group("conductor")
	if !conductor:
		print("NO CONDUCTOR?!?!?!")
	conductor.beat_hit.connect(_on_beat_hit)
	conductor.measure_hit.connect(_on_measure_hit)
	$AnimationPlayer.play("fly_in")

	if start_beat_override >= 0.0:
		start_beat = start_beat_override
	else:
		var earliest : float = conductor.get_song_position() + minimum_lead_beats
		start_beat = ceil(earliest / 4.0) * 4.0
	

	# set the initial scroll offset BEFORE notes exist
	notes_container.position.y = (conductor.get_song_position() - start_beat) * note_spacing
	
	lane_data.clear()
	for i in 4:
		lane_data.append([])
	_load_chart(my_chart)

func _process(_delta: float) -> void:
	notes_container.position.y = (conductor.get_song_position() - start_beat) * note_spacing
	
	if not audio_started and conductor.get_song_position() >= start_beat:
		if plays_audio:
			_play_my_audio()
		audio_started = true
	if autoplay and audio_started:
		for l in 4:
			_judge_note(l)

	# Only allow self-destruct once the pattern has actually begun.
	if audio_started:
		if lane_data[0].is_empty() and lane_data[1].is_empty() \
		and lane_data[2].is_empty() and lane_data[3].is_empty():
			_complete_chart()

func _input(event: InputEvent) -> void:
	if autoplay:
		return
	if Input.is_action_just_pressed("move_left"):
		_judge_note(0)
	if Input.is_action_just_pressed("move_down"):
		_judge_note(1)
	if Input.is_action_just_pressed("move_up"):
		_judge_note(2)
	if Input.is_action_just_pressed("move_right"):
		_judge_note(3)


func _judge_note(judge_lane : int):
	if !lane_data[judge_lane].is_empty():
		# check if rated, then apply judgement, THEN pop
		var judge_note : NoteItem = lane_data[judge_lane][0]
		if judge_note.rated:
			# print(judge_note.rating)
			rating_total += judge_note.rating
			note_resolved.emit(judge_note.rating)
			
			match judge_note.rating:
				2:
					lanes[judge_lane].get_node("AnimatedSprite2D").play("good")
				3:
					lanes[judge_lane].get_node("AnimatedSprite2D").play("perfect")
			lane_data[judge_lane].pop_front()
			judge_note.queue_free()


func _load_chart(chart : Chart):
	notes = chart.notes_for_side(side)
	potential_total = notes.size() * 3

	for note : NoteData in notes:
		var new_note_item = note_item.instantiate()
		new_note_item.position.x = lanes[note.lane].position.x
		new_note_item.position.y = -note.beat * note_spacing
		new_note_item.lane = note.lane
		lane_data[note.lane].append(new_note_item)
		notes_container.add_child(new_note_item)

func _on_note_despawner_area_entered(area: Area2D) -> void:
	if area is NoteItem:
		var kill_spot = lane_data[area.lane].find(area)
		if kill_spot > -1:
			lane_data[area.lane].pop_at(kill_spot)
			note_resolved.emit(0)

func _on_beat_hit() -> void:
	pass

func _on_measure_hit() -> void:
	pass #idk if i'll even use this one, we'll see

func _play_my_audio() -> void:
	var overshoot_beats : float = conductor.get_song_position() - start_beat
	var overshoot_sec : float = overshoot_beats * (60.0 / conductor.bpm)
	if is_finale:
		conductor.finale_player.stream = my_chart.audio
		conductor.finale_player.play(overshoot_sec)   # seek in, don't start at 0
		conductor.audio_player.volume_db = -80.0
	else:
		conductor.action_player.stream = my_chart.audio
		conductor.action_player.play(overshoot_sec)
	
func _complete_chart() -> void:
	var my_score : float = float(rating_total) / float(potential_total)
	chart_completed.emit(my_score)
	if is_finale:
		conductor.audio_player.volume_db = 0.0
	$AnimationPlayer.play("fly_out")
	await $AnimationPlayer.animation_finished
	queue_free()
