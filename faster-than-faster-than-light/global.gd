extends Node


var starship: PackedScene = preload("res://starship.tscn")
var joystick_control: bool = false
var dual_joysticks: bool = false
var music_volume: float = 100.0
var menu_music_progress: float = 0.0
var game_music_progress: float = 0.0
var sfx_volume: float = 100.0
var initialising: bool = true
var playing: bool = false
var tutorial: bool = false
var resources: int
var fuel: int
var starting_fleet: Array[int]
var fleet: Array = []
var max_inventory: int
var jump_distance: float
var charge_rate: float
var crit_chance: float
var galaxy_data: Array = []
var destination: int
var current_system: int
var system_position: Vector2
var visited_systems: Array[int] = []
var unique_visits: int = 0
var joystick_sens: float = 1.5
var next_ship_id: int = -1
var in_combat: bool = false
var controls_showing: bool = true

const DEFAULT_STARTING_FLEET: Array[int] = [0, 1, 1, 2] # Default [0, 1, 1, 2]
const DEFAULT_TUTORIAL_FLEET: Array[int] = [0, 1, 1, 2, 3, 4, 5, 6] # Default [0, 1, 1, 2, 3, 4, 5, 6]
const STARTING_RESOURCES: int = 25 # Default 25
const STARTING_FUEL: int = 25 # Default 25
const STARTING_INVENTORY: Array[int] = [10, 10, 10, 10] # Default []
const TUTORIAL_INVENTORY: Array[int] = [1, 6] # Default [1, 6]
const DEFAULT_INV_SIZE: int = 4 # Default 4
const DEFAULT_JUMP_DISTANCE: float = 140.0 # Default 140.0
const DEFAULT_CHARGE_RATE: float = 3.0 # Default 3.0
const DEFAULT_CRIT_CHANCE: float = 0.0 # Default 0.0

const SECTOR_ROWS: int = 8
const SECTOR_COLUMNS: int = 32
const SECTOR_SIZE: Vector2 = Vector2(100, 70)
const MAX_SECTOR_SYSTEMS: int = 3
const GMAP_TOP: float = 30.0
const GMAP_BOT: float = 590.0
const ENEMY_THRESHOLD: int = 9 # Default 9
const SHOP_THRESHOLD: int = 8 # Default 8
const ITEM_WIN_THRESHOLD: int = 17 # Default 17

var starship_base_stats: Array[Dictionary] = [
	{
		"Hull Strength": 20,
		"Agility": 0.05,
	},
	{
		"Hull Strength": 6,
		"Agility": 0.1,
		"Cost": 60
	},
	{
		"Hull Strength": 5,
		"Agility": 0.1,
		"Cost": 45
	},
	{
		"Hull Strength": 7,
		"Agility": 0.05,
		"Cost": 40
	},
	{
		"Hull Strength": 5,
		"Agility": 0.08,
		"Cost": 50
	},
	{
		"Hull Strength": 6,
		"Agility": 0.1,
		"Cost": 30
	},
	{
		"Hull Strength": 5,
		"Agility": 0.2,
		"Cost": 35
	},
	{
		"Hull Strength": 8,
		"Agility": 0.07,
		"Cost": 75
	},
	{
		"Hull Strength": 1,
		"Agility": 0.4,
	},
	{
		"Hull Strength": 1,
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
		["+5 HULL STRENGTH", "+0.05 AGILITY", "+1 INVENTORY SLOT"],
		["+5 HULL STRENGTH", "+0.05 AGILITY", "+1 INVENTORY SLOT"],
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
		["+2 HULL STRENGTH", "+0.05 AGILITY", "FASTER RECHARGE"],
		["+5 HULL STRENGTH", "+0.05 AGILITY", "FASTER RECHARGE"],
	],
	[
		["+1 HULL STRENGTH", "+0.05 AGILITY", "FASTER REPAIR"],
		["+2 HULL STRENGTH", "FASTER REPAIR", "+1 REPAIR"],
	],
	[
		["+1 HULL STRENGTH", "+0.05 AGILITY", "+5% CRIT CHANCE"],
		["+1 HULL STRENGTH", "+0.1 AGILITY", "+5% CRIT CHANCE"],
	],
	[
		["+1 HULL STRENGTH", "+0.05 AGILITY", "INCREASED RANGE"],
		["+2 HULL STRENGTH", "+0.05 AGILITY", "INCREASED RANGE"],
	],
	[
		["+4 HULL STRENGTH", "+0.01 AGILITY", "+1 DRONE SLOT"],
		["+4 HULL STRENGTH", "+0.02 AGILITY", "+1 DRONE SLOT"],
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
		"Cost": 12,
		"Damage": 1,
		"Reload time": 6.0,
		"Description": "A weak laser weapon, able to do a little bit of damage."
	},
	{ # 1
		"Name": "PHASOR 2",
		"Type": 0,
		"Cost": 24,
		"Damage": 1,
		"Reload time": 4.0,
		"Description": "Faster than the previous model, capable of easily dealing with weaker threats."
	},
	{ # 2
		"Name": "PHASOR 3",
		"Type": 0,
		"Cost": 48,
		"Damage": 1,
		"Reload time": 2.0,
		"Description": "A strong laser weapon which can quickly take out most enemies."
	},
	{ # 3
		"Name": "RAILGUN",
		"Type": 0,
		"Cost": 36,
		"Damage": 3,
		"Reload time": 6.0,
		"Description": "A high damage but somewhat slow reloading laser weapon."
	},
	{ # 4
		"Name": "OBLITERATOR",
		"Type": 0,
		"Cost": 80,
		"Damage": 10,
		"Reload time": 18.0,
		"Description": "Very slow reload, but can tear most ships to shreds when it hits."
	},
	{ # 5
		"Name": "COILGUN 1",
		"Type": 1,
		"Cost": 14,
		"Damage": 1,
		"Reload time": 6.0,
		"Description": "A weak projectile weapon, sacrificing accuracy for the ability to avoid shields."
	},
	{ # 6
		"Name": "COILGUN 2",
		"Type": 1,
		"Cost": 28,
		"Damage": 1,
		"Reload time": 4.0,
		"Description": "Stronger than the first model and able to make light work of defensive starships."
	},
	{ # 7
		"Name": "COILGUN 3",
		"Type": 1,
		"Cost": 56,
		"Damage": 1,
		"Reload time": 2.0,
		"Description": "A very powerful weapon, bombarding enemies with fast firing projectiles."
	},
	{ # 8
		"Name": "GMAT AUTOCOIL",
		"Type": 1,
		"Cost": 840,
		"Damage": 1,
		"Reload time": 0.2,
		"Description": "The latest tech only used by elite fighters. Will make your fleet virtually unstoppable."
	},
	{ # 9
		"Name": "FIGHTER DRONE",
		"Type": 3,
		"Ship type": 8,
		"Cost": 32,
		"Damage": 1,
		"Reload time": 8.0,
		"Description": "A basic fighter drone for use by Drone Command Ships."
	},
	{ # 10
		"Name": "REPAIR DRONE",
		"Type": 3,
		"Ship type": 9,
		"Cost": 42,
		"Damage": 0,
		"Reload time": 15.0,
		"Description": "A basic repair drone for use by Drone Command Ships."
	},
]

const WINNABLE_WEAPONS: Array[int] = [0, 1, 2, 3, 5, 6, 7, 9, 10]

var weapon_types: Array[String] = ["LASER", "PHYSICAL", "EMP", "DRONE"]

var fleet_inventory: Array = [] # Stores the weapon ID


func _process(_delta: float) -> void:
	AudioServer.set_bus_volume_linear(1, music_volume / 100.0)
	AudioServer.set_bus_volume_linear(2, sfx_volume / 100.0)


func establish() -> void:
	# Establish the game
	playing = true
	resources = STARTING_RESOURCES
	fuel = STARTING_FUEL
	max_inventory = DEFAULT_INV_SIZE
	fleet = []
	galaxy_data = []
	visited_systems = []
	unique_visits = 0
	next_ship_id = -1
	in_combat = false
	if tutorial:
		starting_fleet = DEFAULT_TUTORIAL_FLEET
		fleet_inventory = TUTORIAL_INVENTORY.duplicate()
		galaxy_data = [
			{
				"id": 0,
				"position": Vector2(155, 310),
				"sector": 0,
				"enemy presence": false,
				"shop presence": false,
			},
			{
				"id": 1,
				"position": Vector2(235, 310),
				"sector": 1,
				"enemy presence": true,
				"shop presence": false,
			},
			{
				"id": 2,
				"position": Vector2(360, 310),
				"sector": 2,
				"enemy presence": false,
				"shop presence": true,
			},
			{
				"id": 3,
				"position": Vector2(450, 310),
				"sector": 3,
				"enemy presence": false,
				"shop presence": false,
			},
			]
	else:
		starting_fleet = DEFAULT_STARTING_FLEET
		fleet_inventory = STARTING_INVENTORY.duplicate()
		var system_id: int = 0
		# Generate galaxy map
		for row in SECTOR_ROWS:
			for column in SECTOR_COLUMNS:
				for index in randi_range(0, MAX_SECTOR_SYSTEMS):
					var system_type: int = randi_range(0, 19)
					var enemy_presence: bool = false
					var shop_presence: bool = false
					if system_type >= ENEMY_THRESHOLD:
						enemy_presence = true
					elif system_type < ENEMY_THRESHOLD and system_type >= SHOP_THRESHOLD:
						shop_presence = true
					# Set up and store data
					galaxy_data.append({
						"id": system_id,
						"position": Vector2((column * SECTOR_SIZE.x) + (randf() * SECTOR_SIZE.x), GMAP_TOP + (row * SECTOR_SIZE.y) + (randf() * SECTOR_SIZE.y)),
						"sector": column,
						"enemy presence": enemy_presence,
						"shop presence": shop_presence,
					})
					system_id += 1
		
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
	# Same for which is furthest to the right
	var starting_system: Array = [0, 800.0]
	var end_system: Array = [0, 400.0]
	for i in galaxy_data:
		if i["position"].x < starting_system[1]:
			starting_system = [i["id"], i["position"].x]
		elif i["position"].x > end_system[1]:
			end_system = [i["id"], i["position"].x]
	current_system = starting_system[0]
	destination = end_system[0]
	galaxy_data[current_system]["enemy presence"] = false
	galaxy_data[destination]["enemy presence"] = false
	galaxy_data[destination]["shop presence"] = false
	new_system(current_system)
	
	# Create the fleet
	for ship in starting_fleet:
		create_new_starship(ship)
	
	stats_update()


func new_game(tutor: bool = false) -> void:
	print("NEW GAME")
	initialising = true
	tutorial = tutor
	get_tree().change_scene_to_file("res://space.tscn")


func get_new_ship_id() -> int:
	next_ship_id += 1
	return next_ship_id


# Update fleet stats
func stats_update() -> void:
	jump_distance = DEFAULT_JUMP_DISTANCE
	charge_rate = DEFAULT_CHARGE_RATE
	crit_chance = DEFAULT_CRIT_CHANCE
	for ship in fleet:
		if ship.type == 5:
			crit_chance += 0.05 * ship.level
		if ship.type == 6:
			jump_distance += 20.0 * ship.level
			charge_rate += ship.level


# Called when moving to a new system (including at the start)
func new_system(system: int) -> void:
	# Check if the system hasn't been visisted before
	if not visited_systems.has(current_system):
		unique_visits += 1
		visited_systems.append(current_system)
	current_system = system


func create_new_starship(type: int, ship_name: String = "Starship", creator_id: int = -1) -> void:
	var new_ship: Node = starship.instantiate()
	new_ship.id = get_new_ship_id()
	new_ship.team = 1
	new_ship.type = type
	new_ship.alignment = 0
	new_ship.ship_name = ship_name
	new_ship.level = 1
	new_ship.hull_strength = starship_base_stats[type]["Hull Strength"]
	new_ship.hull = starship_base_stats[type]["Hull Strength"]
	new_ship.agility = starship_base_stats[type]["Agility"]
	new_ship.creator_id = creator_id
	if type < 8:
		fleet.append(new_ship)
		get_node("/root/Space/FriendlyShips").add_child(new_ship.duplicate())
	else:
		get_node("/root/Space/Drones").add_child(new_ship)


func create_enemy_ship(type: int, level: int, weapons: Array, creator_id: int = -1) -> void:
	var new_enemy: Node = starship.instantiate()
	new_enemy.id = get_new_ship_id()
	new_enemy.team = -1
	new_enemy.type = type
	new_enemy.alignment = 3
	new_enemy.level = 1
	new_enemy.hull_strength = starship_base_stats[type]["Hull Strength"]
	new_enemy.hull = starship_base_stats[type]["Hull Strength"]
	new_enemy.agility = starship_base_stats[type]["Agility"]
	new_enemy.weapons = weapons
	new_enemy.set_level = level
	new_enemy.creator_id = creator_id
	if type < 8:
		get_node("/root/Space/HostileShips").add_child(new_enemy)
	else:
		get_node("/root/Space/Drones").add_child(new_enemy)
