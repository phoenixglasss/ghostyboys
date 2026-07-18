extends ColorRect

@export var sweep_curve: Curve   # assign a Curve resource in the inspector
var mat: ShaderMaterial

@export var conductor : Conductor

func _ready() -> void:
	mat = material

func _process(_delta: float) -> void:
	var phase: float = fmod(conductor.raw_beat,2.0)        # 0..1 across the beat
	# print(phase)
	var x: float = sweep_curve.sample_baked(phase) # curve maps phase -> lens_x
	# print(x)
	mat.set_shader_parameter("lens_x", (1-x)*1.5 - .25)
