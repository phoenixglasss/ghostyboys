extends CanvasLayer

signal conversation_finished

@onready var portrait_texture: TextureRect = $MainPanel/HBoxContainer/PortraitPanel/PortraitTexture
@onready var speaker_label: Label = $MainPanel/HBoxContainer/VBoxContainer/SpeakerLabel
@onready var dialogue_label: Label = $MainPanel/HBoxContainer/VBoxContainer/DialogueLabel
@onready var typewriter_timer: Timer = $TypewriterTimer

var current_conversation: DialogueConversation
var current_line_index: int = 0
var full_text: String = ""
var char_index: int = 0
var is_typing: bool = false

func _ready() -> void:
	visible = false
	typewriter_timer.timeout.connect(_on_typewriter_timeout)
	
func start_conversation(conversation: DialogueConversation) -> void:
	current_conversation = conversation
	current_line_index = 0
	visible = true
	get_tree().paused = true
	_show_line()
	
func _show_line() -> void:
	var line: DialogueLine = current_conversation.lines[current_line_index]
	speaker_label.text = line.speaker_name
	portrait_texture.texture = line.portrait
	
	full_text = line.text
	char_index = 0
	dialogue_label.text = ""
	is_typing = true
	typewriter_timer.stop()
	typewriter_timer.start()
	
func _on_typewriter_timeout() -> void:
	if char_index < full_text.length():
		dialogue_label.text += full_text[char_index]
		char_index += 1
	else:
		typewriter_timer.stop()
		is_typing = false
		
		
func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if not event.is_action_pressed("interact"):
		return
		

	get_viewport().set_input_as_handled()

	if is_typing:
		typewriter_timer.stop()
		dialogue_label.text = full_text
		char_index = full_text.length()
		is_typing = false
	else:
		_advance()

func _advance() -> void:
	current_line_index += 1
	if current_line_index < current_conversation.lines.size():
		_show_line()
	else:
		_end_conversation()
		

func _end_conversation() -> void:
	visible = false
	get_tree().paused = false
	current_conversation = null
	conversation_finished.emit()
