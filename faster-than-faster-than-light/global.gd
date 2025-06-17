extends Node


var sector_count: int = 8
var sector_size: float = 400
var gmap_top: float = 30
var gmap_bot: float = 590
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
			galaxy_data.append([system_id, Vector2((sector * sector_size) + (randf() * sector_size), randf_range(gmap_top, gmap_bot)), s])
			system_id += 1
		sector += 1
