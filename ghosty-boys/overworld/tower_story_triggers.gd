extends Node

const MelScene := preload("res://overworld/party/mel.tscn")
const JackalScene := preload("res://overworld/party/jackal.tscn")

@export var player: Node2D


func _ready() -> void:
	if not player:
		push_warning("StoryTriggers: Player not assigned in the Inspector!")
		return

	if GameState.apply_return_position:
		player.global_position = GameState.return_position
		GameState.apply_return_position = false

	_check_story_dialogue()
	_check_party_followers()


func _check_story_dialogue() -> void:
	if not GameState.tower_arrival_played:
		DialogueBox.start_conversation(load("res://dialogue/tower/tower_arrival.tres"))
		GameState.tower_arrival_played = true


func _check_party_followers() -> void:
	if not GameState.party_has_mel_and_jackal:
		return
	if get_parent().get_node_or_null("Mel"):
		return

	var mel := MelScene.instantiate()
	get_parent().add_child.call_deferred(mel)
	mel.name = "Mel"
	mel.global_position = player.global_position + Vector2(-8, 0)
	mel.leader = player

	var jackal := JackalScene.instantiate()
	get_parent().add_child.call_deferred(jackal)
	jackal.name = "Jackal"
	jackal.global_position = player.global_position + Vector2(-16, 0)
	jackal.leader = mel
