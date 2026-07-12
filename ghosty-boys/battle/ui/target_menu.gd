extends HBoxContainer
class_name TargetMenu

signal target_chosen(enemy: Dictionary)

func display_targets(living_enemies: Array) -> void:
	for child in get_children():
		child.queue_free()
		
	for enemy in living_enemies:
		var button := Button.new()
		button.text = enemy.data.enemy_name
		button.pressed.connect(_on_target_button_pressed.bind(enemy))
		add_child(button)
		
func _on_target_button_pressed(enemy: Dictionary) -> void:
	target_chosen.emit(enemy)
	
func clear() -> void:
	for child in get_children():
		child.queue_free()
