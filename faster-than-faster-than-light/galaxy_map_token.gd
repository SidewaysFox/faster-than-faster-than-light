extends Area2D


@onready var ui: Node = find_parent("UserInterface")
var id: int
var rotation_rate: float = randf_range(-45.0, 45.0)
var panel_left: float = 365.0
var panel_right: float = 1555.0


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	rotation_degrees += rotation_rate * delta
	# Check if it should be visible on the galaxy map
	if global_position.x > panel_left and global_position.x < panel_right and ui.galaxy_map_showing:
		show()
	else:
		hide()


func _on_timer_timeout() -> void:
	if id == Global.current_system:
		$ColorRect2.show()
		scale = Vector2.ONE * 1.5
	else:
		$ColorRect2.hide()
