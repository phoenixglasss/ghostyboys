@tool
extends Resource
class_name Chart

@export_multiline var parser_string : String = ""
@export var parse : bool = false:
	set(value):
		if(value):
			_parse()
		parse = false

@export var notes : Array[NoteData]


func _parse():
	if parser_string.length() == 4:
		print("valid")
		var new_note = NoteData.new()
		new_note.beat = 0
		new_note.lane = parser_string.find("1")
		new_note.note_type = NoteData.NOTE_TYPE.NONE
		print(new_note)
		notes.append(new_note)
	notify_property_list_changed()
		
