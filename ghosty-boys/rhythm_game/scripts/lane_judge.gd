extends Node2D


func _on_area_okay_area_entered(note: Node2D) -> void:
	if note is NoteItem:
		note.rating = NoteItem.Rating.OKAY

func _on_area_okay_area_exited(note: Node2D) -> void:
	if note is NoteItem:
		note.rating = NoteItem.Rating.MISS

func _on_area_good_area_entered(note: Node2D) -> void:
	if note is NoteItem:
		note.rating = NoteItem.Rating.GOOD

func _on_area_good_area_exited(note: Node2D) -> void:
	if note is NoteItem:
		note.rating = NoteItem.Rating.OKAY

func _on_area_perfect_area_entered(note: Node2D) -> void:
	if note is NoteItem:
		note.rating = NoteItem.Rating.PERFECT

func _on_area_perfect_area_exited(note: Node2D) -> void:
	if note is NoteItem:
		note.rating = NoteItem.Rating.GOOD
