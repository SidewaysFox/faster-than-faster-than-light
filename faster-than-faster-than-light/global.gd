extends Node


var starship: PackedScene = preload("res://starship.tscn")
var joystick_control: bool = false
var dual_joysticks: bool = false
var joystick_sens: float = 1.5
var music_volume: float = 100.0
var sfx_volume: float = 100.0
var menu_music_progress: float = 0.0
var game_music_progress: float = 0.0
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
var next_ship_id: int = -1
var in_combat: bool = false
var controls_showing: bool = true
var continuing: bool = false

const DEFAULT_STARTING_FLEET: Array[int] = [0, 1, 1, 2] # Default [0, 1, 1, 2]
const DEFAULT_TUTORIAL_FLEET: Array[int] = [0, 1, 1, 2, 3, 4, 5, 6]#Default [0, 1, 1, 2, 3, 4, 5, 6]
const MAX_FLEET_SIZE: int = 8 # Default 8
const STARTING_RESOURCES: int = 25 # Default 32
const STARTING_FUEL: int = 32 # Default 25
const STARTING_INVENTORY: Array[int] = [] # Default []
const TUTORIAL_INVENTORY: Array[int] = [1, 6] # Default [1, 6]
const DEFAULT_INV_SIZE: int = 4 # Default 4
const DEFAULT_JUMP_DISTANCE: float = 140.0 # Default 140.0
const DEFAULT_CHARGE_RATE: float = 3.0 # Default 3.0
const DEFAULT_CRIT_CHANCE: float = 0.0 # Default 0.0
const JUMP_DISTANCE_UPGRADE: float = 20.0 # Default 20.0
const CRIT_CHANCE_UPGRADE: float = 0.05 # Default 0.05

const SECTOR_ROWS: int = 8 # Default 8
const SECTOR_COLUMNS: int = 32 # Default 32
const SECTOR_SIZE: Vector2 = Vector2(100, 70) # Default (100, 70)
const MAX_SECTOR_SYSTEMS: int = 3 # Default 3
const GMAP_TOP: float = 30.0 # Default 30.0
const GMAP_BOT: float = 590.0 # Default 590.0
const SYSTEM_TYPE_THRESHOLD: int = 19 # Default 19
const ENEMY_THRESHOLD: int = 9 # Default 9
const SHOP_THRESHOLD: int = 8 # Default 8
const ITEM_WIN_THRESHOLD: int = 17 # Default 17

const VOLUME_FACTOR: float = 100.0
const MUSIC_BUS: int = 1
const SFX_BUS: int = 2

enum Teams {
	HOSTILE = -1,
	NEUTRAL,
	FRIENDLY
}

enum StarshipTypes {
	COMMAND_SHIP,
	FIGHTER,
	SHIELD,
	INFILTRATION,
	REPAIR,
	SCANNER,
	RELAY,
	DRONE_COMMAND,
	FIGHTER_DRONE,
	REPAIR_DRONE
	}

enum Liveries {
	ALLIANCE,
	PIRATE_YELLOW,
	PIRATE_GREEN,
	PIRATE_PURPLE
}

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

var upgrade_costs: Array[Array] = [
	[85, 90],
	[60, 95],
	[50, 65],
	[55, 90],
	[45, 80],
	[45, 60],
	[45, 60],
	[90, 95],
	]

var upgrade_specifications: Array[Array] = [
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

var ship_actions: Array[Array] = [
	["N/A", "N/A"],
	["OPEN FIRE!", "CEASE FIRE!"],
	["ACTIVATE SHIELDS!", "DEACTIVATE SHIELDS!"],
	["ENGAGE ENEMIES!", "DISENGAGE!"],
	["REPAIR BEAMS ON!", "REPAIR BEAMS OFF!"],
	["SCANNERS ON!", "SCANNERS OFF!"],
	["N/A", "N/A"],
	["ACTIVATE DRONES!", "DEACTIVATE DRONES!"],
]

var possible_names: Array[String] = [
	"STRONGARM", "POWER", "FRAY", "PEREGRIN", "FALCON", "STORM", "BRAWN", "HAZE", "CRACKDOWN",
	"DART", "QUASAR", "PILGRIM", "LOCKDOWN", "GREATAXE", "NOVA", "DEADEYE", "DESTINY", "SCALAR",
	"VECTOR", "MATRIX", "GHOST", "PHANTOM", "OWL", "CRYSTAL", "VERMILLION", "PIKE", "SPEARHEAD",
	"BASIS", "ANGLER", "ESSENCE", "FULCRUM", "HALO", "ICHOR", "JET", "JEWEL", "KILO", "LANTERN",
	"MAESTRO", "OCULAR", "RAVEN", "PLACEBO", "SURGE", "TROJAN", "UMBRA", "WAYFARER", "SCORN",
	"ZERO", "PULSAR", "ANDROMEDA", "WOLF", "FOX", "RANGER", "JUDICATOR", "TENSOR", "NEBULA",
	"GALAXY", "BASTION", "AEGIS", "TOTEM", "BULWARK", "PHALANX", "HERO", "SNAKE", "XENOLITH",
	"XEMA", "STALWART", "HORIZON", "BAILIFF", "STALLION", "ANACONDA", "WYVERN", "WHALE", "MOLE",
	"BASKEMTBALL", "CLAW", "DUKE", "ASTRA", "EAGLE", "ALTUS", "ATLAS", "BREVIS", "CELER", "CLAM",
	"DEFENESTRATOR", "MUSCLE", "BARNACLE", "CANINE", "WHIRLWIND", "TORNADO", "TYPHOON", "REVEREND",
	"TOME", "HAWK", "NARWHAL", "SCIMITAR", "EXIMUS", "SHOCKWAVE", "BUCCANEER", "CUTLASS", "GLADIUS",
	"SABRE", "KATANA", "MACE", "TALWAR", "SCOURGE", "SPIKE", "BULLPUP", "YUKON"
]

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
	{ # 11
		"Name": "RAILGUN DRONE",
		"Type": 3,
		"Ship type": 8,
		"Cost": 85,
		"Damage": 3,
		"Reload time": 6.0,
		"Description": "A fighter drone equipped with a specialised laser railgun."
	},
	{ # 12
		"Name": "REPAIR DRONE 2",
		"Type": 3,
		"Ship type": 9,
		"Cost": 105,
		"Damage": 0,
		"Reload time": 7.5,
		"Description": "An advanced and extremely capable repair drone."
	},
	{ # 13
		"Name": "FIGHTER DRONE 2",
		"Type": 3,
		"Ship type": 8,
		"Cost": 64,
		"Damage": 1,
		"Reload time": 4.0,
		"Description": "An advanced fighter drone, great for breaking down enemy shields."
	},
]

var weapon_types: Array[String] = ["LASER", "PHYSICAL", "EMP", "DRONE"]

enum WeaponTypes {
	LASER,
	PHYSICAL,
	EMP,
	DRONE
}

var fleet_inventory: Array = [] # Stores the weapon ID

# Pool from which random drops are pulled (as such some weapons are doubled to modify chances)
const WINNABLE_WEAPONS: Array[int] = [
	0, 0, 0, 0,
	1, 1, 1,
	2, 2,
	3, 3,
	5, 5, 5, 5,
	6, 6, 6,
	7, 7,
	9, 9, 9,
	10, 10, 10,
	11, 11,
	12,
	13,
]

const ENEMY_TARGETERS: Array[int] = [1, 3, 5]

const STATUS_MESSAGES: Array[String] = ["STATUS: OK", "STATUS: UNDER ATTACK"]

# This can't be a constant, otherwise it makes everything else a constant
var tutorial_galaxy: Array[Dictionary] = [
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


func _ready() -> void:
	# Load settings
	var config: ConfigFile = ConfigFile.new()
	var err: Error = config.load("user://settings.cfg")
	if err == OK:
		music_volume = config.get_value("Settings", "music_volume")
		sfx_volume = config.get_value("Settings", "sfx_volume")
		joystick_control = config.get_value("Settings", "joystick_control")
		dual_joysticks = config.get_value("Settings", "dual_joysticks")
	AudioServer.set_bus_volume_linear(MUSIC_BUS, music_volume / VOLUME_FACTOR)
	AudioServer.set_bus_volume_linear(SFX_BUS, sfx_volume / VOLUME_FACTOR)


func _process(_delta: float) -> void:
	# Change audio bus volumes
	AudioServer.set_bus_volume_linear(MUSIC_BUS, music_volume / VOLUME_FACTOR)
	AudioServer.set_bus_volume_linear(SFX_BUS, sfx_volume / VOLUME_FACTOR)


func establish() -> void:
	# Establish the game
	playing = true
	in_combat = false
	# Load save if continuing game
	var config: ConfigFile = ConfigFile.new()
	var err: Error = config.load("user://save.cfg")
	if continuing and err == OK: # Continuing
		resources = config.get_value("Game", "resources")
		fuel = config.get_value("Game", "fuel")
		max_inventory = config.get_value("Game", "max_inventory")
		galaxy_data = config.get_value("Game", "galaxy_data")
		visited_systems = config.get_value("Game", "visited_systems")
		unique_visits = config.get_value("Game", "unique_visits")
		next_ship_id = config.get_value("Game", "next_ship_id")
		fleet_inventory = config.get_value("Game", "fleet_inventory")
		current_system = config.get_value("Game", "current_system")
		destination = config.get_value("Game", "destination")
		
		# Because config files can't store the starships properly when the game has been closed
		# Needs to load info for each ship individually
		fleet = []
		for ship in config.get_value("Game", "fleet"):
			var new_ship: Node3D = starship.instantiate()
			new_ship.id = ship.id
			new_ship.team = ship.team
			new_ship.type = ship.type
			new_ship.livery = ship.livery
			new_ship.ship_name = ship.ship_name
			new_ship.level = ship.level
			new_ship.hull_strength = ship.hull_strength
			new_ship.hull = ship.hull
			new_ship.agility = ship.agility
			new_ship.weapons = ship.weapons
			new_ship.drones = ship.drones
			new_ship.status = ship.status
			new_ship.active = ship.active
			new_ship.shield_layers = ship.shield_layers
			fleet.append(new_ship)
	else: # New game
		resources = STARTING_RESOURCES
		fuel = STARTING_FUEL
		max_inventory = DEFAULT_INV_SIZE
		fleet = []
		galaxy_data = []
		visited_systems = []
		unique_visits = 0
		next_ship_id = -1
		# Is this the tutorial?
		if tutorial:
			starting_fleet = DEFAULT_TUTORIAL_FLEET
			fleet_inventory = TUTORIAL_INVENTORY.duplicate()
			galaxy_data = tutorial_galaxy
		else:
			starting_fleet = DEFAULT_STARTING_FLEET
			fleet_inventory = STARTING_INVENTORY.duplicate()
			var system_id: int = 0
			# Generate galaxy map
			for row in SECTOR_ROWS:
				for column in SECTOR_COLUMNS:
					for index in randi_range(0, MAX_SECTOR_SYSTEMS):
						var system_type: int = randi_range(0, SYSTEM_TYPE_THRESHOLD)
						var enemy_presence: bool = false
						var shop_presence: bool = false
						if system_type >= ENEMY_THRESHOLD:
							enemy_presence = true
						elif system_type < ENEMY_THRESHOLD and system_type >= SHOP_THRESHOLD:
							shop_presence = true
						# Set up and store data
						galaxy_data.append({
							"id": system_id,
							"position": (
									Vector2((column * SECTOR_SIZE.x) + (randf() * SECTOR_SIZE.x),
									GMAP_TOP + (row * SECTOR_SIZE.y) + (randf() * SECTOR_SIZE.y))
							),
							"sector": column,
							"enemy presence": enemy_presence,
							"shop presence": shop_presence,
						})
						system_id += 1
		
		# Check which system is furthest to the left
		# Same for which is furthest to the right
		var MAX_START_X: float = 800.0
		var MIN_END_X: float = 400.0
		var starting_system: Array = [0, MAX_START_X]
		var end_system: Array = [0, MIN_END_X]
		for node in galaxy_data:
			if node["position"].x < starting_system[1]:
				starting_system = [node["id"], node["position"].x]
			elif node["position"].x > end_system[1]:
				end_system = [node["id"], node["position"].x]
		current_system = starting_system[0]
		destination = end_system[0]
		# Make sure nothing too interesting 
		galaxy_data[current_system]["enemy presence"] = false
		galaxy_data[destination]["enemy presence"] = false
		galaxy_data[destination]["shop presence"] = false
		new_system(current_system)
		
		# Create the fleet
		for ship in starting_fleet:
			create_new_starship(ship)
	
	stats_update()


# Starting new game
func new_game(is_tutorial: bool = false) -> void:
	var main_scene: String = "res://space.tscn"
	print("NEW GAME")
	initialising = true
	tutorial = is_tutorial
	get_tree().change_scene_to_file(main_scene)


# For creating new ships and incrementing the id
func get_new_ship_id() -> int:
	next_ship_id += 1
	return next_ship_id


# Update fleet stats
func stats_update() -> void:
	jump_distance = DEFAULT_JUMP_DISTANCE
	charge_rate = DEFAULT_CHARGE_RATE
	crit_chance = DEFAULT_CRIT_CHANCE
	for ship in fleet:
		if ship.type == StarshipTypes.SCANNER:
			crit_chance += CRIT_CHANCE_UPGRADE * ship.level
		if ship.type == StarshipTypes.RELAY:
			jump_distance += JUMP_DISTANCE_UPGRADE * ship.level
			charge_rate += ship.level


# Called when moving to a new system (including at the start)
func new_system(system: int) -> void:
	# Check if the system hasn't been visisted before
	if not visited_systems.has(current_system):
		unique_visits += 1
		visited_systems.append(current_system)
	current_system = system


# Creating new friendly starships
func create_new_starship(type: int, ship_name: String = "Starship", creator_id: int = -1) -> void:
	var new_ship: Node3D = starship.instantiate()
	new_ship.id = get_new_ship_id()
	new_ship.team = Teams.FRIENDLY
	new_ship.type = type
	new_ship.livery = Liveries.ALLIANCE
	new_ship.ship_name = ship_name
	new_ship.level = 1
	new_ship.hull_strength = starship_base_stats[type]["Hull Strength"]
	new_ship.hull = starship_base_stats[type]["Hull Strength"]
	new_ship.agility = starship_base_stats[type]["Agility"]
	new_ship.creator_id = creator_id
	if type < StarshipTypes.FIGHTER_DRONE:
		fleet.append(new_ship)
		get_node("/root/Space/FriendlyShips").add_child(new_ship.duplicate())
	else:
		get_node("/root/Space/Drones").add_child(new_ship)


# Creating new hostile ships
func create_enemy_ship(type: int, level: int, weapons: Array, creator_id: int = -1) -> void:
	var new_enemy: Node3D = starship.instantiate()
	new_enemy.id = get_new_ship_id()
	new_enemy.team = Teams.HOSTILE
	new_enemy.type = type
	new_enemy.livery = randi_range(Liveries.PIRATE_YELLOW, Liveries.PIRATE_PURPLE)
	new_enemy.level = 1
	new_enemy.hull_strength = starship_base_stats[type]["Hull Strength"]
	new_enemy.hull = starship_base_stats[type]["Hull Strength"]
	new_enemy.agility = starship_base_stats[type]["Agility"]
	if type == StarshipTypes.DRONE_COMMAND:
		new_enemy.drones = weapons
	else:
		new_enemy.weapons = weapons
	new_enemy.set_level = level
	new_enemy.creator_id = creator_id
	if type < StarshipTypes.FIGHTER_DRONE:
		get_node("/root/Space/HostileShips").add_child(new_enemy)
	else:
		get_node("/root/Space/Drones").add_child(new_enemy)


# Saving all required game variables
func save_game() -> void:
	var config: ConfigFile = ConfigFile.new()
	config.set_value("Game", "resources", resources)
	config.set_value("Game", "fuel", fuel)
	config.set_value("Game", "max_inventory", max_inventory)
	config.set_value("Game", "fleet", fleet)
	config.set_value("Game", "galaxy_data", galaxy_data)
	config.set_value("Game", "visited_systems", visited_systems)
	config.set_value("Game", "unique_visits", unique_visits)
	config.set_value("Game", "next_ship_id", next_ship_id)
	config.set_value("Game", "fleet_inventory", fleet_inventory)
	config.set_value("Game", "destination", destination)
	config.set_value("Game", "current_system", current_system)
	config.save("user://save.cfg")
