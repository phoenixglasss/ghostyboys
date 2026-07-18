extends Node

const MelScene := preload("res://overworld/party/mel.tscn")
const JackalScene := preload("res://overworld/party/jackal.tscn")

@export var player: Node2D
@export var exit_door: ExitDoor


func _ready() -> void:
	_check_story_dialogue()
	_check_party_followers()
	
func _check_story_dialogue() -> void:
	if not GameState.intro_dialogue_played:
		DialogueBox.start_conversation(load("res://dialogue/bar/daisy_arrival.tres"))
		GameState.intro_dialogue_played = true
	elif GameState.tutorial_fight_won and not GameState.closing_dialogue_played:
		DialogueBox.start_conversation(load("res://dialogue/bar/mel_jackal_closing.tres"))
		await DialogueBox.conversation_finished
		GameState.closing_dialogue_played = true
		GameState.party_has_mel_and_jackal = true
		exit_door.unlock()
		_check_party_followers()
		
func _check_party_followers() -> void:
	if not GameState.party_has_mel_and_jackal:
		return
	if get_parent().get_node_or_null("Mel"):
		return
			
	var mel := MelScene.instantiate()
	get_parent().add_child(mel)
	mel.name = "Mel"
	mel.global_position = player.global_position + Vector2(-8, 0)
	mel.leader = player
		
	var jackal := JackalScene.instantiate()
	get_parent().add_child(jackal)
	jackal.name = "Jackal"
	jackal.global_position = player.global_position + Vector2(-16, 0)
	jackal.leader = mel
