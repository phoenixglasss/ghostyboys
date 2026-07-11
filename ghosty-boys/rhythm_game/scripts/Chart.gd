@tool
extends Resource
class_name Chart

@export_multiline var parser_string : String = ""
@export var parse : bool = false:
	set(value):
		if(value):
			_parse()
		parse = false

@export var beats_per_bar : int = 4
@export var notes : Array[NoteData]


func _parse():
	notes.clear()
	var import_measures = parser_string.split(",")
	var m = 0
	for measure in import_measures:
		# strip the nasty empty lines, they messes up our calculations they do
		var measure_notes : Array[String] = []
		for line in measure.split("\n"):
			var clean := line.strip_edges()
			if clean.length() == 4:
				measure_notes.append(clean)
		
		if measure_notes.is_empty():
			m += 1
			continue
		
		var note_length : float = float(beats_per_bar) / measure_notes.size()
		print("Notes are " + str(note_length) + " long")
		for i in measure_notes.size():
			var row : String = measure_notes[i]
			var beat : float = (m * beats_per_bar) + (i * note_length)
			print(str(beat) + ": " + str(row))
			for lane in 4:
				if row[lane] == "1":
					var new_note = NoteData.new()
					new_note.beat = beat
					new_note.lane = lane
					notes.append(new_note)
		m += 1
	
	notify_property_list_changed()
