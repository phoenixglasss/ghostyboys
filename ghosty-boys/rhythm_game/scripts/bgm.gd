extends Resource
class_name BGM

@export var audio : AudioStream = preload("res://audio/music/battle/battle_bgm.ogg")
@export var bpm : float = 137.0
@export var attack_sounds : Dictionary[String, AudioStream]
