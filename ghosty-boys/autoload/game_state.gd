extends Node

var party: Array[PartyMember] = []
var defeated_enemies: Array[Dictionary] = []
var pending_encounter: EncounterData
var return_scene_path: String
var return_position: Vector2

func _ready() -> void:
	party = [
		load("res://data/party_members/daisy.tres"),
		load("res://data/party_members/mel.tres"),
		load("res://data/party_members/jackal.tres")
	]

func log_defeat(enemy_name: String, method: String, zone: String) -> void:
	defeated_enemies.append({"enemy_name": enemy_name, "method": method, "zone": zone})
