extends Resource

class_name EnemyData

@export var enemy_name: String
@export var max_hp: int
@export var zone_theme: String
@export var destroy_threshold: float = 0.5
@export var banish_threshold: float = 0.2
@export var moveset: Array[AttackData]
