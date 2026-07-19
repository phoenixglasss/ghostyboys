extends AnimatedSprite2D

var anims = ["walk_down", "walk_left", "walk_up", "walk_right"]
var index = 0
var timer = 0.0
var beat = 60.0 / 137.0

func _ready():
	play(anims[0])

func _process(delta):
	timer += delta
	if timer >= beat:
		timer -= beat
		index = (index + 1) % anims.size()
		play(anims[index])
