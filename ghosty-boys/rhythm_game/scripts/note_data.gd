extends Resource
class_name NoteData

@export var beat : float
@export var lane : int

enum NOTE_TYPE {
	NONE, HOLD_START, HOLD_END
}

@export var note_type : NOTE_TYPE
