extends Resource
class_name EncounterData

@export var encounter_name: String
@export var enemies: Array[EnemyData]
@export var background: Texture2D
@export var intro_conversation: DialogueConversation
@export var allow_destroy: bool = true
