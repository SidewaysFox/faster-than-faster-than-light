extends Node


var sector_count: int = 8
var sector_system_count: int = 25
var joystick_sens: float = 1.5
var galaxy_data: Array = []
var current_system: int
var jump_distance: int = 4


func _ready() -> void:
	var sector: int = 0
	var system_id: int = 0
	for s in sector_count:
		for n in sector_system_count:
			galaxy_data.append([system_id, Vector2((sector * 800) + (randf() * 800), randf_range(60, 1560)), s])
			system_id += 1
		sector += 1
