extends Node2D


@onready var ui: Node = find_parent("UserInterface")
var id: int
var rotation_rate: float = randf_range(-45.0, 45.0)


func _process(delta: float) -> void:
	rotation_degrees += rotation_rate * delta
	if global_position.x > 380.0 and global_position.x < 3020.0 and ui.galaxy_map_showing:
		show()
	else:
		hide()
