extends Resource
class_name EncounterData

@export var encounter_name: String
@export var enemies: Array[EnemyData]
@export var background: Texture2D
@export var intro_conversation: DialogueConversation
@export var is_tutorial_fight: bool = false
@export var post_battle_position: Vector2
@export var unlocks_scrapyard_gate: bool = false
@export var victory_destination_scene: String = ""
