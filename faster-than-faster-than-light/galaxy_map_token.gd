extends Node2D


@onready var ui: Node = find_parent("UserInterface")


func _process(delta: float) -> void:
	if global_position.x > 380.0 and global_position.x < 3020.0 and ui.galaxy_map_showing:
		show()
	else:
		hide()
