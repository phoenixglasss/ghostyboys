extends Camera2D
class_name BattleCamera

const HOME := Vector2(160, 90)

var _shake_amount := 0.0
var _shake_decay := 0.0
var _noise_t := 0.0
var _noise := FastNoiseLite.new()

var _zoom_tween: Tween

func _ready() -> void:
	position = HOME
	anchor_mode = Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT if false else anchor_mode
	_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	_noise.frequency = 1.0

# --- shake ---
# amount = max pixel offset, duration = seconds to fall to zero
func shake(amount: float, duration: float = 0.25) -> void:
	_shake_amount = max(_shake_amount, amount)
	_shake_decay = amount / max(duration, 0.001)

func _process(delta: float) -> void:
	if _shake_amount > 0.0:
		_noise_t += delta * 30.0
		offset = Vector2(
			_noise.get_noise_2d(_noise_t, 0.0),
			_noise.get_noise_2d(0.0, _noise_t)
		) * _shake_amount
		# snap to whole pixels if you're on a pixel-perfect viewport
		offset = offset.round()
		_shake_amount = max(_shake_amount - _shake_decay * delta, 0.0)
		if _shake_amount == 0.0:
			offset = Vector2.ZERO

# --- bump zoom ---
# scale > 1.0 punches in, < 1.0 punches out
func bump_zoom(scale: float = 1.15, in_time: float = 0.06, out_time: float = 0.2) -> void:
	if _zoom_tween and _zoom_tween.is_running():
		_zoom_tween.kill()
	zoom = Vector2.ONE
	_zoom_tween = create_tween()
	_zoom_tween.tween_property(self, "zoom", Vector2.ONE * scale, in_time)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_zoom_tween.tween_property(self, "zoom", Vector2.ONE, out_time)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
