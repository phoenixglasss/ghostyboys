extends Node


var defeated_enemies: Array[Dictionary] = []


func log_defeat(enemy_name: String, method: String, zone: String) -> void:
	defeated_enemies.append({"enemy_name": enemy_name, "method": method, "zone": zone})
