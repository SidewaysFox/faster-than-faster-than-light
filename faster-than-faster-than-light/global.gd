extends Node


var starship: PackedScene = preload("res://starship.tscn")
var initilising: bool = true
var resources: int = 0
var fuel: int = 45
var fleet: Array = []
var sector_count: int = 8
var sector_size: float = 400
var gmap_top: float = 30
var gmap_bot: float = 590
var sector_system_count: int = 25
var joystick_sens: float = 1.5
var galaxy_data: Array = []
var current_system: int
var system_position: Vector2
var unique_visits: int = 0
var visited_systems: Array[int] = []
var jump_distance: float = 180.0


func _ready() -> void:
	print("go")
	var sector: int = 0
	var system_id: int = 0
	var starting_system: Array = [0, 800.0]
	for s in sector_count:
		for n in sector_system_count:
			galaxy_data.append([system_id, Vector2((sector * sector_size) + (randf() * sector_size), randf_range(gmap_top, gmap_bot)), s])
			system_id += 1
		sector += 1
	for i in galaxy_data:
		if i[1].x < starting_system[1]:
			starting_system = [i[0], i[1].x]
	current_system = starting_system[0]
	new_system(current_system)
	
	var new_ship: Node = starship.instantiate()
	new_ship.team = 1
	new_ship.hull_strength = 20
	fleet.append(new_ship)
	get_node("/root/Space/FriendlyShips").add_child(new_ship.duplicate())
	
	for i in 2:
		new_ship = starship.instantiate()
		new_ship.team = 1
		new_ship.type = 1
		fleet.append(new_ship)
		get_node("/root/Space/FriendlyShips").add_child(new_ship.duplicate())


func new_system(system: int) -> void:
	if not visited_systems.has(system):
		unique_visits += 1
		visited_systems.append(system)
	current_system = system
	if unique_visits > 1:
		initilising = false
