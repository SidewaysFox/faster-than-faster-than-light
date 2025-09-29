extends Area2D


@onready var ui: Node = find_parent("UserInterface")
var id: int
var rotation_rate: float = randf_range(-45.0, 45.0)
var panel_left: float = 365.0
var panel_right: float = 1555.0


func _process(delta: float) -> void:
	# Spin
	rotation_degrees += rotation_rate * delta
	$Range.scale = Vector2.ONE * (Global.jump_distance / 100.0)


# This is slightly delayed instead of being on the _ready() function so that it
# uses updated data
func _on_timer_timeout() -> void:
	# Check if this token represents the current system
	if id == Global.current_system:
		$ColorRect2.show()
		Global.system_position = position
		$Range.show()
	else:
		$ColorRect2.hide()
		$Range.hide()
		if Global.visited_systems.has(id):
			$ColorRect.color = Color(1, 1, 0)
	if Global.galaxy_data[id]["shop presence"]:
		$ShopIndicator.show()
