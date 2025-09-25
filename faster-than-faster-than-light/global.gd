extends Node


var starship: PackedScene = preload("res://starship.tscn")
var joystick_control: bool = false
var dual_joysticks: bool = true
var music_volume: float = 100.0
var sfx_volume: float = 100.0
var initialising: bool = true
var playing: bool = true
var resources: int = 0
var fuel: int = 80
var starting_fleet: Array[int] = [0, 1, 1, 2, 3, 4, 6]
var fleet: Array = []
var jump_distance: float = 120.0
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
		"Agility": 0.05,
	},
	{
		"Hull Strength": 6,
		"Agility": 0.1,
	},
	{
		"Hull Strength": 5,
		"Agility": 0.1,
	},
	{
		"Hull Strength": 8,
		"Agility": 0.05,
	},
	{
		"Hull Strength": 5,
		"Agility": 0.08,
	},
	{
		"Hull Strength": 6,
		"Agility": 0.1,
	},
	{
		"Hull Strength": 5,
		"Agility": 0.2,
	},
	{
		"Hull Strength": 8,
		"Agility": 0.07,
	},
	{
		"Hull Strength": 3,
		"Agility": 0.4,
	},
	{
		"Hull Strength": 3,
		"Agility": 0.4,
	},
]

var upgrade_costs: Array = [
	[85, 90],
	[60, 95],
	[50, 65],
	[55, 90],
	[45, 80],
	[45, 60],
	[45, 60],
	[90, 95],
	]

var upgrade_specifications: Array = [
	[
		["+5 HULL STRENGTH", "+0.05 AGILITY", "+1 MODULE SLOT"],
		["+5 HULL STRENGTH", "+0.05 AGILITY", "+1 MODULE SLOT"],
	],
	[
		["+2 HULL STRENGTH", "+0.05 AGILITY", "+1 WEAPON SLOT"],
		["+4 HULL STRENGTH", "+0.1 AGILITY", "+1 WEAPON SLOT"],
	],
	[
		["+2 HULL STRENGTH", "+0.05 AGILITY", "+1 SHIELD LAYER"],
		["+3 HULL STRENGTH", "+0.05 AGILITY", "+1 SHIELD LAYER"],
	],
	[
		["+2 HULL STRENGTH", "+0.05 AGILITY", "LONGER STUN"],
		["+5 HULL STRENGTH", "+0.05 AGILITY", "LONGER STUN"],
	],
	[
		["+1 HULL STRENGTH", "+0.05 AGILITY", "FASTER REPAIR"],
		["+2 HULL STRENGTH", "FASTER REPAIR", "+1 REPAIR"],
	],
	[
		["+1 HULL STRENGTH", "+0.05 AGILITY", "+1 SCANNED SHIPS"],
		["+1 HULL STRENGTH", "+0.1 AGILITY", "+1 SCANNED SHIPS"],
	],
	[
		["+1 HULL STRENGTH", "+0.05 AGILITY", "INCREASED RANGE"],
		["+2 HULL STRENGTH", "+0.05 AGILITY", "INCREASED RANGE"],
	],
	[
		["+4 HULL STRENGTH", "+1 DRONE SLOT", "REPAIR DRONES"],
		["+4 HULL STRENGTH", "+2 DRONE SLOTS", "NONE"],
	],
]

var ship_actions: Array = [
	["N/A", "N/A"],
	["OPEN FIRE!", "CEASE FIRE!"],
	["ACTIVATE SHIELDS!", "DEACTIVATE SHIELDS!"],
	["ENGAGE ENEMIES!", "DISENGAGE!"],
	["REPAIR BEAMS ON!", "REPAIR BEAMS OFF!"],
	["SCANNERS ON!", "SCANNERS OFF!"],
	["N/A", "N/A"],
	["ACTIVATE DRONES!", "DEACTIVATE DRONES!"],
]

var possible_names: Array[String] = ["STRONGARM", "POWER", "FRAY", "PEREGRIN", "FALCON", "STORM", \
		"BRAWN", "HAZE", "CRACKDOWN", "DART", "QUASAR", "PILGRIM", "LOCKDOWN", "GREATAXE", "NOVA", \
		"DEADEYE", "DESTINY", "SCALAR", "VECTOR", "MATRIX", "GHOST", "PHANTOM", "OWL", "CRYSTAL", \
		"VERMILLION", "PIKE", "SPEARHEAD", "BASIS", "ANGLER", "ESSENCE", "FULCRUM", "HALO", \
		"ICHOR", "JET", "JEWEL", "KILO", "LANTERN", "MAESTRO", "OCULAR", "RAVEN", "PLACEBO", \
		"SURGE", "TROJAN", "UMBRA", "WAYFARER", "SCORN", "ZERO", "PULSAR", "ANDROMEDA", "WOLF", \
		"FOX", "RANGER", "JUDICATOR", "TENSOR", "NEBULA", "GALAXY", "BASTION", "AEGIS", "TOTEM", \
		"BULWARK", "PHALANX", "HERO", "SNAKE", "XENOLITH", "XEMA", "STALWART", "HORIZON", \
		"BAILIFF", "STALLION", "ANACONDA", "WYVERN", "WHALE", "MOLE", "BASKEMTBALL", "CLAW", \
		"DUKE", "ASTRA", "EAGLE", "ALTUS", "ATLAS", "BREVIS", "CELER", "CLAM", "DEFENESTRATOR", \
		"MUSCLE", "BARNACLE", "CANINE", "WHIRLWIND", "TORNADO", "TYPHOON", "REVEREND", "TOME", \
		"HAWK", "NARWHAL", "SCIMITAR", "EXIMUS", "SHOCKWAVE", "BUCCANEER", "CUTLASS", "GLADIUS", \
		"SABRE", "KATANA", "MACE", "TALWAR", "SCOURGE", "SPIKE", "BULLPUP", "YUKON"]

var weapon_list: Array[Dictionary] = [
	{ # 0
		"Name": "PHASOR 1",
		"Type": 0,
		"Cost": 15,
		"Damage": 1,
		"Reload time": 6.0
	},
	{ # 1
		"Name": "PHASOR 2",
		"Type": 0,
		"Cost": 30,
		"Damage": 1,
		"Reload time": 4.0
	},
	{ # 2
		"Name": "PHASOR 3",
		"Type": 0,
		"Cost": 60,
		"Damage": 1,
		"Reload time": 2.0
	},
	{ # 3
		"Name": "RAILGUN",
		"Type": 0,
		"Cost": 55,
		"Damage": 3,
		"Reload time": 6.0
	},
	{ # 4
		"Name": "OBLITERATOR",
		"Type": 0,
		"Cost": 80,
		"Damage": 10,
		"Reload time": 12.0
	},
	{ # 5
		"Name": "COILGUN 1",
		"Type": 1,
		"Cost": 15,
		"Damage": 1,
		"Reload time": 6.0
	},
	{ # 6
		"Name": "COILGUN 2",
		"Type": 1,
		"Cost": 30,
		"Damage": 1,
		"Reload time": 4.0
	},
	{ # 7
		"Name": "COILGUN 3",
		"Type": 1,
		"Cost": 60,
		"Damage": 1,
		"Reload time": 2.0
	},
	{
		"Name": "GMAT AUTOCOIL",
		"Type": 1,
		"Cost": 250,
		"Damage": 1,
		"Reload time": 0.1
	},
]

var weapon_types: Array[String] = ["LASER", "PHYSICAL", "BEAM"]

var fleet_inventory: Array = [
	3,
	1,
	4,
	5,
	6,
	8,
]


func establish() -> void:
	playing = true
	resources = 25
	fuel = 80
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
				var system_type: int = randi_range(0, 19)
				var enemy_presence: bool = false
				var shop_presence: bool = false
				if system_type >= 9:
					enemy_presence = true
				elif system_type == 8:
					shop_presence = true
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
	jump_distance = 120.0
	for ship in fleet:
		if ship.type == 6:
			jump_distance += 20 * ship.level
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
	new_enemy.id = get_new_ship_id()
	new_enemy.team = -1
	new_enemy.type = type
	new_enemy.alignment = 3
	new_enemy.level = 1
	new_enemy.hull_strength = starship_base_stats[type]["Hull Strength"]
	new_enemy.hull = starship_base_stats[type]["Hull Strength"]
	new_enemy.agility = starship_base_stats[type]["Agility"]
	get_node("/root/Space/HostileShips").add_child(new_enemy)
