extends HBoxContainer
class_name TargetMenu

signal target_chosen(enemy: Dictionary)

func display_targets(living_enemies: Array) -> void:
	visible = true
	for child in get_children():
		child.queue_free()
		
	for enemy in living_enemies:
		var button := Button.new()
		button.text = enemy.data.enemy_name
		button.add_theme_font_size_override("font_size", 8)
		button.pressed.connect(_on_target_button_pressed.bind(enemy))
		button.mouse_entered.connect(_on_target_button_hovered.bind(enemy, true))
		button.mouse_exited.connect(_on_target_button_hovered.bind(enemy, false))
		add_child(button)
		
	print("TargetMenu populated: ", get_child_count(), " children, visible = ", visible)
		
func _on_target_button_pressed(enemy: Dictionary) -> void:
	target_chosen.emit(enemy)
	
func _on_target_button_hovered(enemy: Dictionary, hovering: bool) -> void:
	if enemy.display:
		enemy.display.set_highlighted(hovering)
	
	
func clear() -> void:
	visible = false
	for child in get_children():
		child.queue_free()
