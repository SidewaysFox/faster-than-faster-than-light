extends Control


var fading: bool = false

const FADE_RATE: float = 1.4
const SPEED: float = 30.0


func _process(delta: float) -> void:
	# Constant fade until queue freeing
	global_position.y -= SPEED * delta
	if fading:
		modulate.a -= FADE_RATE * delta
		if modulate.a <= 0.0:
			queue_free()


# Start fading
func _on_timer_timeout() -> void:
	fading = true
