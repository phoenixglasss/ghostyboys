extends Button

@export var chart : Chart
var chart_display : PackedScene = preload("res://rhythm_game/scenes/chart_display.tscn")

func _ready() -> void:
	pressed.connect(_press)

func _press() -> void:
	var new_chart_display : ChartDisplay = chart_display.instantiate()
	new_chart_display.my_chart = chart
	get_tree().root.add_child(new_chart_display)
