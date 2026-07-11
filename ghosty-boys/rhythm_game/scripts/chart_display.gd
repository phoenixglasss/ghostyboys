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
	lane_data.clear()
	for i in 4:
		lane_data.append([])
		
	_load_chart(my_chart)
	
func _process(delta: float) -> void:
	notes_container.position.x = -conductor.get_song_position() * note_spacing + (initial_offset_beats * note_spacing)
	print(conductor.get_song_position())
	
	
func _input(event: InputEvent) -> void:
	pass

func _judge_note(judge_lane : int):
	pass

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

	
