extends Node

var party: Array[PartyMember] = []
var defeated_enemies: Array[Dictionary] = []
var pending_encounter: EncounterData
var return_scene_path: String
var return_position: Vector2
var cleared_triggers: Array[String] = []
var pending_trigger_id: String = ""

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
