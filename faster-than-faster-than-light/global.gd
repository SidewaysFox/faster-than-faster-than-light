extends Node


var starship: PackedScene = preload("res://starship.tscn")
var joystick_control: bool = false
var dual_joysticks: bool = true
var initilising: bool = true
var playing: bool = true
var resources: int = 0
var fuel: int = 45
var starting_fleet: Array[int] = [0, 1, 1, 6]
var fleet: Array = []
var jump_distance: float = 180.0
var charge_rate: float = 2.0
var augmentations: Array = []
var galaxy_data: Array = []
var sector_count: int = 8
var sector_size: float = 400
var sector_system_count: int = 25
var gmap_top: float = 30
var gmap_bot: float = 590
var current_system: int
var system_position: Vector2
var visited_systems: Array[int] = []
var unique_visits: int = 0
var joystick_sens: float = 1.5
var next_ship_id: int = -1
var in_combat: bool = false

var starship_base_stats: Array[Dictionary] = [
	{
		"Hull Strength": 20,
		"Agility": 0.1,
	},
	{
		"Hull Strength": 6,
		"Agility": 0.2,
	},
	{
		"Hull Strength": 5,
		"Agility": 0.2,
	},
	{
		"Hull Strength": 8,
		"Agility": 0.15,
	},
	{
		"Hull Strength": 6,
		"Agility": 0.15,
	},
	{
		"Hull Strength": 6,
		"Agility": 0.25,
	},
	{
		"Hull Strength": 8,
		"Agility": 0.25,
	},
	{
		"Hull Strength": 10,
		"Agility": 0.12,
	},
	{
		"Hull Strength": 3,
		"Agility": 0.4,
	},
	{
		"Hull Strength": 3,
		"Agility": 0.35,
	},
]

var weapon_list: Array[Dictionary] = [
	{
		"Name": "Phasor 1",
		"Type": 0,
		"Slots": 1,
		"Damage": 1,
		"Reload time": 7.0
	},
	{
		"Name": "Phasor 2",
		"Type": 0,
		"Slots": 2,
		"Damage": 1,
		"Reload time": 5.0
	},
	{
		"Name": "Phasor 3",
		"Type": 0,
		"Slots": 3,
		"Damage": 1,
		"Reload time": 3.0
	},
]


func establish() -> void:
	playing = true
	resources = 0
	fuel = 45
	fleet = []
	jump_distance = 180.0
	charge_rate = 2.0
	augmentations = []
	galaxy_data = []
	visited_systems = []
	unique_visits = 0
	next_ship_id = -1
	in_combat = false
	# Establish the game
	var sector: int = 0
	var system_id: int = 0
	var starting_system: Array = [0, 800.0]
	# Generate galaxy map
	for s in sector_count:
		for n in sector_system_count: # ID, position, sector, enemy presence
			var enemy_presence: bool
			if randi_range(1, 3) == 3:
				enemy_presence = true
			else:
				enemy_presence = false
			# Set up and store the data
			galaxy_data.append({
				"id": system_id,
				"position": Vector2((sector * sector_size) + (randf() * sector_size), randf_range(gmap_top, gmap_bot)),
				"sector": s,
				"enemy presence": enemy_presence
				})
			system_id += 1
		sector += 1
	# Check which system is furthest to the left
	for i in galaxy_data:
		if i["position"].x < starting_system[1]:
			starting_system = [i["id"], i["position"].x]
	current_system = starting_system[0]
	new_system(current_system)
	
	# Create the fleet
	for ship in starting_fleet:
		create_new_starship(ship)
	
	stats_update()


func new_game() -> void:
	print("NEW GAME")
	initilising = true
	get_tree().change_scene_to_file("res://space.tscn")


func get_new_ship_id() -> int:
	next_ship_id += 1
	return next_ship_id


# Update fleet stats
func stats_update() -> void:
	jump_distance = 100.0
	for ship in fleet:
		if ship.type == 6:
			jump_distance += 25 * ship.level
			charge_rate += ship.level


# Called when moving to a new system (including at the start)
func new_system(system: int) -> void:
	# Check if the system hasn't been visisted before
	if not visited_systems.has(system):
		unique_visits += 1
		visited_systems.append(system)
	current_system = system
	# Check if this is the first system
	if unique_visits > 1:
		initilising = false


func create_new_starship(type: int) -> void:
	var new_ship: Node = starship.instantiate()
	new_ship = starship.instantiate()
	new_ship.id = get_new_ship_id()
	new_ship.team = 1
	new_ship.type = type
	new_ship.alignment = 0
	new_ship.level = 1
	new_ship.hull_strength = starship_base_stats[type]["Hull Strength"]
	new_ship.hull = starship_base_stats[type]["Hull Strength"]
	new_ship.agility = starship_base_stats[type]["Agility"]
	fleet.append(new_ship)
	get_node("/root/Space/FriendlyShips").add_child(new_ship.duplicate())


func create_enemy_ship(type: int) -> void:
	var new_enemy: Node = starship.instantiate()
	new_enemy.id = Global.get_new_ship_id()
	new_enemy.team = -1
	new_enemy.type = type
	new_enemy.alignment = 3
	new_enemy.level = 1
	new_enemy.hull_strength = starship_base_stats[type]["Hull Strength"]
	new_enemy.hull = starship_base_stats[type]["Hull Strength"]
	new_enemy.agility = starship_base_stats[type]["Agility"]
	get_node("/root/Space/HostileShips").add_child(new_enemy)
