extends VBoxContainer

class_name ActionMenu

signal action_chosen(attack: AttackData)
signal finisher_chosen(method: String)

func display_moves(moveset: Array[AttackData], available_finishers: Array[String] = []) -> void:
	for child in get_children():
		child.queue_free()
		
	for attack in moveset:
		var button := Button.new()
		button.text = attack.attack_name
		button.pressed.connect(_on_move_button_pressed.bind(attack))
		add_child(button)
		
	for method in available_finishers:
		var button := Button.new()
		button.text = method
		button.pressed.connect(_on_finisher_button_pressed.bind(method))
		add_child(button)
		
func _on_finisher_button_pressed(method: String) -> void:
	finisher_chosen.emit(method)
		
		
func _on_move_button_pressed(attack: AttackData) -> void:
	action_chosen.emit(attack)
	
func clear() -> void:
	for child in get_children():
		child.queue_free()
