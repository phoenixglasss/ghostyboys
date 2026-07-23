extends HBoxContainer

class_name ActionMenu

signal action_chosen(attack: AttackData)

const ATTACK_NAME_FONT_SIZE: int = 8
const DESCRIPTION_FONT_SIZE: int = 7

func display_moves(moveset: Array[AttackData]) -> void:
	visible = true
	for child in get_children():
		child.queue_free()

	for attack in moveset:
		var button := Button.new()
		button.text = attack.attack_name
		button.custom_minimum_size = Vector2(70, 0)
		button.size_flags_vertical = Control.SIZE_FILL
		button.clip_text = false
		button.add_theme_font_size_override("font_size", ATTACK_NAME_FONT_SIZE)
		button.autowrap_mode = TextServer.AUTOWRAP_WORD
		button.pressed.connect(_on_move_button_pressed.bind(attack))
		button.mouse_entered.connect(_on_move_button_hovered.bind(button, attack, true))
		button.mouse_exited.connect(_on_move_button_hovered.bind(button, attack, false))
		add_child(button)
		
		
func _on_move_button_hovered(button: Button, attack: AttackData, hovering: bool) -> void:
	if hovering and attack.description != "":
		button.text = attack.description
		button.add_theme_font_size_override("font_size", DESCRIPTION_FONT_SIZE)
	else:
		button.text = attack.attack_name
		button.add_theme_font_size_override("font_size", ATTACK_NAME_FONT_SIZE)
		
func _on_move_button_pressed(attack: AttackData) -> void:
	action_chosen.emit(attack)
	
func clear() -> void:
	visible = false
	for child in get_children():
		child.queue_free()
	print("ActionMenu cleared, TargetMenu visible is now: ", get_parent().get_node("TargetMenu").visible)
