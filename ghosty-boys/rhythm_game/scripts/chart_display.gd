extends Node2D

@export var conductor : Conductor

@export var lanes : Array[Node2D]
var notes : Array[NoteData]
var note_spacing : float = 48

@export var my_chart : Chart
@onready var hit_line : Node2D = $HitLine
@onready var notes_container : Node2D = $HitLine/Notes

@export var initial_offset_beats : int = 4


var lane_data : Array[Array] = []

var note_item = preload("res://rhythm_game/scenes/note_item.tscn")

func _ready() -> void:
	conductor.beat_hit.connect(_on_beat_hit)
	conductor.measure_hit.connect(_on_measure_hit)
	
	
	lane_data.clear()
	for i in 4:
		lane_data.append([])
		
	_load_chart(my_chart)
	
func _process(delta: float) -> void:
	notes_container.position.x = -conductor.get_song_position() * note_spacing + (initial_offset_beats * note_spacing)
	
	
func _input(event: InputEvent) -> void:
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
		var judge_note : NoteItem = lane_data[judge_lane].pop_front()
		print(judge_note.rating)
		judge_note.queue_free()

func _load_chart(chart : Chart):
	notes = chart.notes
	
	for note : NoteData in notes:
		var new_note_item = note_item.instantiate()
		new_note_item.position.y = lanes[note.lane].position.y
		new_note_item.position.x = note.beat * note_spacing
		new_note_item.lane = note.lane
		lane_data[note.lane].append(new_note_item)
		notes_container.add_child(new_note_item)
	
	print(lane_data)


func _on_note_despawner_area_entered(area: Area2D) -> void:
	if area is NoteItem:
		var kill_spot = lane_data[area.lane].find(area)
		if kill_spot > -1:
			lane_data[area.lane].pop_at(kill_spot)


func _on_beat_hit() -> void:
	pass

func _on_measure_hit() -> void:
	pass #idk if i'll even use this one, we'll see
