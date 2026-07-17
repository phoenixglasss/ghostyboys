extends ColorRect

@export var sweep_curve: Curve   # assign a Curve resource in the inspector
var mat: ShaderMaterial

@export var conductor : Conductor

func _ready() -> void:
	mat = material
	
func _process(_delta: float) -> void:
	mat.set_shader_parameter("noise_offset", Vector2(randf(), randf()))
