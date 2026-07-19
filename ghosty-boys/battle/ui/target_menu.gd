extends HBoxContainer
class_name TargetMenu

signal target_chosen(target)

func display_targets(living_targets: Array) -> void:
	visible = true
	for child in get_children():
		child.queue_free()
		
	for target in living_targets:
		var button := Button.new()
		button.text = target.member_name if target is PartyMember else target.data.enemy_name
		button.add_theme_font_size_override("font_size", 7)
		button.pressed.connect(_on_target_button_pressed.bind(target))
		add_child(button)
		
	print("TargetMenu populated: ", get_child_count(), " children, visible = ", visible)
		
func _on_target_button_pressed(target) -> void:
	target_chosen.emit(target)
	
func _on_target_button_hovered(enemy: Dictionary, hovering: bool) -> void:
	pass
	
	
func clear() -> void:
	visible = false
	for child in get_children():
		child.queue_free()
