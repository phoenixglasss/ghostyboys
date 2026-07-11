extends Node2D

@export var lanes : Array[Node2D]
var notes : Array[NoteData]
var note_spacing : float = 48

@export var my_chart : Chart
@onready var hit_line : Node2D = $HitLine

var note_item = preload("res://rhythm_game/scenes/note_item.tscn")

func _ready() -> void:
	_load_chart(my_chart)

func _load_chart(chart : Chart):
	notes = chart.notes
	
	for note : NoteData in notes:
		var new_note_item = note_item.instantiate()
		new_note_item.position.y = lanes[note.lane].position.y
		new_note_item.position.x = note.beat * note_spacing
		new_note_item.lane = note.lane
		hit_line.add_child(new_note_item)
	
