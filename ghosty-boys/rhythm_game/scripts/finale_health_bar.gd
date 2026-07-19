extends ProgressBar

@export var conductor : Conductor

func _ready() -> void:
	if !conductor:
		conductor = get_tree().get_first_node_in_group("conductor")
	visible = false
	conductor.finale_health_changed.connect(_on_health_changed)
	conductor.finale_player_died.connect(func(): visible = false)

func _on_health_changed(current : float, max_health : float) -> void:
	visible = true
	max_value = max_health
	value = current
