extends Resource
class_name EnemyData

@export var enemy_name: String
@export var max_hp: int
@export var zone_theme: String
@export var sprite_frames: SpriteFrames
@export var overworld_sprite_frames: SpriteFrames
@export var moveset: Array[AttackData]
@export var finale_threshold: int = 0
@export var finale_chart: Chart
