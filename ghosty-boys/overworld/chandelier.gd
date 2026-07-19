extends Area2D
var player : Node2D
var player_init_x : float
var init_x : float
@export var parallax_factor : float = 0.1

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	player_init_x = player.position.x
	init_x = position.x   # sprite's own starting x
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	var new_x = init_x - (player.position.x - player_init_x) * parallax_factor
	position.x = lerp(position.x, new_x, 0.02)


func _on_body_entered(body: Node2D) -> void:
	if body == player:
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.2, 0.2)

func _on_body_exited(body: Node2D) -> void:
	if body == player:
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 1.0, 0.2)
