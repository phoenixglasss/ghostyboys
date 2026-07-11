extends VBoxContainer

class_name ActionMenu

signal action_chosen(attack: AttackData)

func display_moves(moveset: Array[AttackData]) -> void:
	for child in get_children():
		child.queue_free()
		
	for attack in moveset:
		var button := Button.new()
		button.text = attack.attack_name
		button.pressed.connect(_on_move_button_pressed.bind(attack))
		add_child(button)
		
		
func _on_move_button_pressed(attack: AttackData) -> void:
	action_chosen.emit(attack)
	
func clear() -> void:
	for child in get_children():
		child.queue_free()
