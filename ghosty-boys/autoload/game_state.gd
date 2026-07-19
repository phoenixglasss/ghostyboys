extends Node

var party: Array[PartyMember] = []
var defeated_enemies: Array[Dictionary] = []
var pending_encounter: EncounterData
var return_scene_path: String
var return_position: Vector2
var apply_return_position: bool = false
var cleared_triggers: Array[String] = []
var pending_trigger_id: String = ""
var interaction_counts: Dictionary = {}
var intro_dialogue_played: bool = false
var bar_unlocked: bool = false
var tutorial_fight_won: bool = false
var closing_dialogue_played: bool = false
var party_has_mel_and_jackal: bool = false
var mel_survivors_suggestion_played: bool = false
var dover_intro_played: bool = false
var dave_banter_played: bool = false
var scrapyard_gate_won: bool = false
var tower_arrival_played: bool = false
var boss_intro_played: bool = false
var final_boss_defeated: bool = false

func _ready() -> void:
	party = [
		load("res://data/party_members/daisy.tres"),
		load("res://data/party_members/mel.tres"),
		load("res://data/party_members/jackal.tres")
	]

func log_defeat(enemy_name: String, method: String, zone: String) -> void:
	defeated_enemies.append({"enemy_name": enemy_name, "method": method, "zone": zone})


func mark_trigger_cleared(trigger_id: String) -> void:
	if trigger_id not in cleared_triggers:
		cleared_triggers.append(trigger_id)
		
		
func is_trigger_cleared(trigger_id: String) -> bool:
	return trigger_id in cleared_triggers

func get_interaction_count(interactable_id: String) -> int:
	return interaction_counts.get(interactable_id, 0)
	
func increment_interaction_count(interactable_id: String) -> void:
	interaction_counts[interactable_id] = get_interaction_count(interactable_id) + 1
