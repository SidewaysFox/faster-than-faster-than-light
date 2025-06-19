extends Area2D


@onready var ui: Node = find_parent("UserInterface")
var id: int
var rotation_rate: float = randf_range(-45.0, 45.0)
var panel_left: float = 365.0
var panel_right: float = 1555.0


func _process(delta: float) -> void:
	rotation_degrees += rotation_rate * delta


func _on_timer_timeout() -> void:
	if id == Global.current_system:
		$ColorRect2.show()
		Global.system_position = position
		$Range.scale = Vector2.ONE * (Global.jump_distance / 100)
		$Range.show()
	else:
		$ColorRect2.hide()
		$Range.hide()
