extends Node2D


func _on_area_okay_area_entered(note: NoteItem) -> void:
	note.rating = NoteItem.Rating.OKAY

func _on_area_okay_area_exited(note: NoteItem) -> void:
	note.rating = NoteItem.Rating.MISS

func _on_area_good_area_entered(note: NoteItem) -> void:
	note.rating = NoteItem.Rating.GOOD

func _on_area_good_area_exited(note: NoteItem) -> void:
	note.rating = NoteItem.Rating.OKAY

func _on_area_perfect_area_entered(note: NoteItem) -> void:
	note.rating = NoteItem.Rating.PERFECT

func _on_area_perfect_area_exited(note: NoteItem) -> void:
	note.rating = NoteItem.Rating.GOOD
