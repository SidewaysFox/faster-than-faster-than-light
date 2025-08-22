extends Node


var starship: PackedScene = preload("res://starship.tscn")
var joystick_control: bool = false
var dual_joysticks: bool = true
var music_volume: float = 100.0
var sfx_volume: float = 100.0
var initialising: bool = true
var playing: bool = true
var resources: int = 0
var fuel: int = 45
var starting_fleet: Array[int] = [0, 1, 1, 4]
var fleet: Array = []
var jump_distance: float = 180.0
var charge_rate: float = 2.0
var augmentations: Array = []
var galaxy_data: Array = []
var current_system: int
var system_position: Vector2
var visited_systems: Array[int] = []
var unique_visits: int = 0
var joystick_sens: float = 1.5
var next_ship_id: int = -1
var in_combat: bool = false
var controls_showing: bool = true

const SECTOR_ROWS: int = 8
const SECTOR_COLUMNS: int = 32
const SECTOR_SIZE: Vector2 = Vector2(100, 70)
const MAX_SECTOR_SYSTEMS: int = 3
const GMAP_TOP: float = 30.0
const GMAP_BOT: float = 590.0

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
	for row in SECTOR_ROWS:
		for column in SECTOR_COLUMNS:
			for index in randi_range(0, MAX_SECTOR_SYSTEMS):
				var system_type: int = randi_range(0, 20)
				var enemy_presence: bool = false
				var shop_presence: bool = false
				var quest_presence: bool = false
				if system_type >= 12:
					enemy_presence = true
				elif system_type == 11:
					shop_presence = true
				elif system_type == 10:
					quest_presence = true
				# Set up and store data
				galaxy_data.append({
					"id": system_id,
					"position": Vector2((column * SECTOR_SIZE.x) + (randf() * SECTOR_SIZE.x), GMAP_TOP + (row * SECTOR_SIZE.y) + (randf() * SECTOR_SIZE.y)),
					"sector": column,
					"enemy presence": enemy_presence
				})
				system_id += 1
			sector += 1
	
	#for c in SECTOR_COLUMNS:
		#for n in MAX_SECTOR_SYSTEMS: # ID, position, sector, enemy presence
			#var enemy_presence: bool
			#if randi_range(1, 3) == 3:
				#enemy_presence = true
			#else:
				#enemy_presence = false
			## Set up and store the data
			#galaxy_data.append({
				#"id": system_id,
				#"position": Vector2((sector * SECTOR_SIZE.x) + (randf() * SECTOR_SIZE.x), randf_range(GMAP_TOP, GMAP_BOT)),
				#"sector": c,
				#"enemy presence": enemy_presence
				#})
			#system_id += 1
		#sector += 1
	
	# Check which system is furthest to the left
	for i in galaxy_data:
		if i["position"].x < starting_system[1]:
			starting_system = [i["id"], i["position"].x]
	current_system = starting_system[0]
	galaxy_data[current_system]["enemy presence"] = false
	new_system(current_system)
	
	# Create the fleet
	for ship in starting_fleet:
		create_new_starship(ship)
	
	stats_update()


func new_game() -> void:
	print("NEW GAME")
	initialising = true
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
	if not visited_systems.has(current_system):
		unique_visits += 1
		visited_systems.append(current_system)
	current_system = system


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
