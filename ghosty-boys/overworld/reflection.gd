extends Node2D

@export var source : Node2D

var sprites : Array[Node]

var reflection_sprite : AnimatedSprite2D
var source_sprite : AnimatedSprite2D

func _ready() -> void:
	sprites = source.get_children().filter(
		func(c): return c is AnimatedSprite2D and c != self
	)
	if (!sprites.is_empty()):
		source_sprite = sprites[0]
		
		reflection_sprite = AnimatedSprite2D.new()
		reflection_sprite.sprite_frames = source_sprite.sprite_frames
		reflection_sprite.flip_v = true
		reflection_sprite.position.y -= source_sprite.position.y
		reflection_sprite.modulate = Color8(255,255,60,60)
		add_child(reflection_sprite)

func _process(delta: float) -> void:
	reflection_sprite.animation = source_sprite.animation
	reflection_sprite.frame = source_sprite.frame
	position = source.position
