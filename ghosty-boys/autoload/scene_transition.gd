extends CanvasLayer

@onready var fade_rect: ColorRect = $FadeRect

const FADE_DURATION: float = 0.4
const BATTLE_SCENE_PATH: String = "res://battle/battle_scene.tscn"

func go_to_battle(encounter: EncounterData) -> void:
	GameState.pending_encounter = encounter
	GameState.return_scene_path = get_tree().current_scene.scene_file_path
	var player := get_tree().get_first_node_in_group("player")
	if player:
		GameState.return_position = player.global_position
		
	await _fade_to(1.0)
	get_tree().change_scene_to_file(BATTLE_SCENE_PATH)
	await _fade_to(0.0)
	
func return_to_overworld() -> void:
	print("Returning to: ", GameState.return_scene_path)
	await _fade_to(1.0)
	get_tree().change_scene_to_file(GameState.return_scene_path)
	await get_tree().process_frame
	var player := get_tree().get_first_node_in_group("player")
	if player:
		player.global_position = GameState.return_position
	await _fade_to(0.0)
	
func _fade_to(target_alpha: float) -> void:
	var tween := create_tween()
	tween.tween_property(fade_rect, "color:a", target_alpha, FADE_DURATION)
	await tween.finished
