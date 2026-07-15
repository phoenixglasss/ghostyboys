extends HBoxContainer

class_name ActionMenu
signal destroy_chosen

signal action_chosen(attack: AttackData)

func display_moves(moveset: Array[AttackData], show_destroy: bool = false) -> void:
	visible = true
	for child in get_children():
		child.queue_free()

	for attack in moveset:
		var button := Button.new()
		button.text = attack.attack_name
		button.add_theme_font_size_override("font_size", 8)
		button.pressed.connect(_on_move_button_pressed.bind(attack))
		add_child(button)

	if show_destroy:
		var button := Button.new()
		button.text = "Destroy"
		button.add_theme_font_size_override("font_size", 8)
		button.pressed.connect(_on_destroy_button_pressed)
		add_child(button)


func _on_destroy_button_pressed() -> void:
	destroy_chosen.emit()
		
func _on_move_button_pressed(attack: AttackData) -> void:
	action_chosen.emit(attack)
	
func clear() -> void:
	visible = false
	for child in get_children():
		child.queue_free()
	print("ActionMenu cleared, TargetMenu visible is now: ", get_parent().get_node("TargetMenu").visible)
