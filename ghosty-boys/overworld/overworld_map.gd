extends Node2D
class_name OverworldMap

@export var bgm : AudioStream
var bgm_player : AudioStreamPlayer

func _ready() -> void:
	bgm_player = AudioStreamPlayer.new()
	add_child.call_deferred(bgm_player)
	await bgm_player.ready
	if bgm:
		bgm_player.stream = bgm
		bgm_player.play()
	
