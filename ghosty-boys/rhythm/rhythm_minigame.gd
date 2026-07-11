extends Node

signal challenge_completed(result: Dictionary)

func start_challenge(move_name: String) -> void:
	print("Rhythm challenge started for: ", move_name)
	await get_tree().create_timer(0.5).timeout
	var fake_percentage := randf_range(0.5, 1.0)
	challenge_completed.emit({"percentage": fake_percentage})
