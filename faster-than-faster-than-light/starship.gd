class_name Starship extends Node3D


@export_category("Properties")
## The starship's ID, used to identify it in data storage
@export var id: int
## What team the starship is on
@export var team: int
# -1: Hostile
# 0: Neutral
# 1: Friendly
## The starship's type
@export var type: int
# 0: Command ship
# 1: Fighter
# 2: Shield
# 3: Infiltration
# 4: Repair
# 5: Scanner
# 6: Relay
# 7: drone command ship
# 8: drone fighter
# 9: drone repair
## The starship's livery
@export var livery: int
# 0: Alliance
# 1: Pirate Yellow
# 2: Pirate Green
# 3: Pirate Purple
## The starship's name
@export var ship_name: String = "Starship"
## The starship's current level
@export var level: int
## The starship's maximum hull points
@export var hull_strength: int
## The starship's chance to avoid enemy weapons
@export var agility: float
## The starship's currently active weapons
@export var weapons: Array = [0]
## The starship's available drone slots
@export var drones: Array = [9]
@export_category("Misc")
## Ship meshes
@export var meshes: Array[PackedScene] = []
## Projectiles
@export var projectiles: Array[PackedScene] = []
## Sound effects
@export var warp_sfx: Array[AudioStreamOggVorbis] = []

# General variables
@onready var main: Node3D = get_node("/root/Space")
@onready var ui: Control = get_node("/root/Space/CanvasLayer/UserInterface")
@onready var hostile_ships: Node3D = main.get_node("HostileShips")
@onready var friendly_ships: Node3D = main.get_node("FriendlyShips")
@onready var all_drones: Node3D = main.get_node("Drones")
@export_category("Bugfixing")
@export var hull: int # WHY DOES THIS NEED TO BE EXPORTED
var status: int
var active: bool = true
var target: Node3D
var shield_layers: int
var attacked: bool = false
var scanned: bool = false
var drones_deployed: bool = false
var is_drone: bool = false
var creator_id: int
var jumping: bool = true
var jump_mode: int = -1
var jump_destination: float
var warp_destination: float
var spawn_location: Vector3
var marker: StyleBoxFlat

# AI variables
var set_level: int
var targeting_strategy: int = randi_range(0, 2)

enum Strategies {
	STATIC,
	DELAYED,
	RANDOM
}

enum EquipmentAdditions {
	FIGHTER,
	DRONE_TWO = 9,
	DRONE_THREE = 10
}

const MAX_LEVEL: int = 3
const START_POS_MOD: Vector3 = Vector3(-2000.0, 60.0, -100)
const JUMP_DESTINATION_OFFSET: Vector2 = Vector2(-120, -50)
const DEFAULT_NAME: String = "Starship"
const DRONE_NAME: String = "DRONE"
const PIRATE_NAME: String = "PIRATE"
const INFILTRATE_RECHARGE: float = 19.0
const INFILTRATE_UPGRADE: float = 3.0
const REPAIR_TIME: float = 15.0
const REPAIR_UPGRADE: float = 3.0
const REPAIR_VALUES: Array[int] = [0, 1, 1, 2]
const DRONE_RESIZE: Vector3 = Vector3.ONE * 0.5
const WARP_OUT_SFX_DELAY: float = 0.9
const WARP_IN_SFX_DELAY: float = 0.4
const RETARGET_DELAY: Vector2 = Vector2(16.0, 32.0)
const JUMP_DELAY: float = 2.0
const MARKER_SELECTION_ALPHA: float = 0.4
const MARKER_HOVER_ALPHA: Vector2 = Vector2(1.0, 0.63)
const BORDER_COLOUR_ON: Color = Color8(0, 191, 255)
const BORDER_COLOUR_OFF: Color = Color8(255, 255, 255)
const NAME_LABEL: String = "NAME: "
const TYPE_LABEL: String = "TYPE: "
const HULL_LABEL: String = "HULL: "
const BAR_FACTOR: float = 100.0
const RELOAD_HOLD: float = 0.1
const JUMP_LERP: float = 0.1
const QUARTER_ROTATION: float = PI / 2.0

const UPGRADES: Array[Dictionary] = [
	{
		"Hull1": 5,
		"Agility1": 0.05,
		"Hull2": 5,
		"Agility2": 0.05,
	},
	{
		"Hull1": 2,
		"Agility1": 0.05,
		"Hull2": 4,
		"Agility2": 0.1,
	},
	{
		"Hull1": 2,
		"Agility1": 0.05,
		"Hull2": 3,
		"Agility2": 0.05,
	},
	{
		"Hull1": 2,
		"Agility1": 0.05,
		"Hull2": 5,
		"Agility2": 0.05,
	},
	{
		"Hull1": 1,
		"Agility1": 0.05,
		"Hull2": 2,
		"Agility2": 0.0,
	},
	{
		"Hull1": 1,
		"Agility1": 0.05,
		"Hull2": 1,
		"Agility2": 0.1,
	},
	{
		"Hull1": 1,
		"Agility1": 0.05,
		"Hull2": 2,
		"Agility2": 0.05,
	},
	{
		"Hull1": 4,
		"Agility1": 0.01,
		"Hull2": 4,
		"Agility2": 0.02,
		"1": 9,
		"2": 10
	},
]


func _ready() -> void:
	# Apply appropriate mesh based on type
	var new_mesh: Node3D = meshes[type].instantiate()
	new_mesh.type = livery
	add_child(new_mesh)
	
	marker = $Marker/Selection.get_theme_stylebox("panel")
	
	# Is this ship a drone?
	if type > Global.StarshipTypes.DRONE_COMMAND:
		is_drone = true
		scale = DRONE_RESIZE
	
	# Set up the ship's name
	if ship_name == DEFAULT_NAME and team == Global.Teams.FRIENDLY:
		if is_drone:
			ship_name = DRONE_NAME
		else:
			ship_name = Global.possible_names.pop_at(randi_range(0, len(Global.possible_names) - 1))
	elif team != Global.Teams.FRIENDLY:
		ship_name = PIRATE_NAME
		for l in set_level:
			upgrade()
	
	# Starting location based on team
	if team != Global.Teams.NEUTRAL:
		global_position = Vector3(
				START_POS_MOD.x * team,
				randf_range(-START_POS_MOD.y, START_POS_MOD.y),
				randf_range(START_POS_MOD.z, 0.0)
		)
		rotation.y = QUARTER_ROTATION - ((PI * team) / 2.0)
		
		# Also set up marker colouration while you're at it
		if team == 1:
			marker.border_color = Color.WHITE
		else:
			marker.border_color = Color.DARK_RED
			# Targeting timer, too
			if targeting_strategy == Strategies.DELAYED:
				$Retarget.start(randf_range(RETARGET_DELAY.x, RETARGET_DELAY.y))
	else:
		global_position = Vector3.ZERO
		jumping = false
	jump_destination = randf_range(JUMP_DESTINATION_OFFSET.x, JUMP_DESTINATION_OFFSET.y) * team
	warp_destination = -global_position.x
	$JumpDelay.start(1 + (randf() * JUMP_DELAY))
	
	# Set up appropriate timers
	if type == Global.StarshipTypes.FIGHTER or type == Global.StarshipTypes.FIGHTER_DRONE:
		var index: int = 1
		for weapon_id in weapons:
			get_node("WeaponReload" + str(index)).wait_time = (
					Global.weapon_list[weapon_id]["Reload time"]
			)
			index += 1
	elif type == Global.StarshipTypes.SHIELD:
		shield_layers = level
	elif type == Global.StarshipTypes.INFILTRATION:
		$InfiltrateReload.wait_time = INFILTRATE_RECHARGE - (level * INFILTRATE_UPGRADE)
	elif type == Global.StarshipTypes.REPAIR or type == Global.StarshipTypes.REPAIR_DRONE:
		$RepairReload.wait_time = REPAIR_TIME - (level * REPAIR_UPGRADE)


func _process(_delta: float) -> void:
	# Has this ship been destroyed?
	if hull <= 0:
		if team == Global.Teams.FRIENDLY and not is_drone:
			Global.fleet.remove_at(get_data_location())
		# Delete all of its drones if it's a drone command ship
		if type == Global.StarshipTypes.DRONE_COMMAND:
			for drone in all_drones.get_children():
				if drone.creator_id == id:
					drone.hull = 0
		queue_free()
	
	# Ship marker stuff
	$Marker.hide()
	# Drones don't have markers
	if not is_drone and ui.visible:
		var selected_friendly: bool = ui.selected_ship == get_index()
		# Whether or not the marker's actually showing in the first place
		if (
				(team == Global.Teams.FRIENDLY
						and (ui.action_menu_showing
								or selected_friendly)
				)
				or (team == Global.Teams.HOSTILE
						and scanned)
		):
			$Marker.show()
			
			$Marker/Reload1.hide()
			$Marker/Reload2.hide()
			$Marker/Reload3.hide()
			# Change marker properties based on player input
			# This statement needs to be distinct/separate because it won't let me construct the Color8
			# alongside the alpha channel variable. As such, this is the best alternative solution
			if ui.selected_ship == get_index() and team == Global.Teams.FRIENDLY:
				marker.border_color = BORDER_COLOUR_ON
			else:
				marker.border_color = BORDER_COLOUR_OFF
			# Friendly markers
			if team == Global.Teams.FRIENDLY:
				if ui.selected_ship == get_index():
					$Marker.modulate.a = 1.0
				else:
					$Marker.modulate.a = MARKER_SELECTION_ALPHA
				if (
						ui.hovered_ship == get_index()
						or (ui.hovered_target == get_index()
								and ui.targeting_mode == Global.StarshipTypes.REPAIR)
				):
					marker.border_color.a = MARKER_HOVER_ALPHA.x
				else:
					marker.border_color.a = MARKER_HOVER_ALPHA.y
			# Hostile markers
			elif team == Global.Teams.HOSTILE:
				if (
						ui.hovered_target == get_index()
						and ui.targeting_mode != Global.StarshipTypes.REPAIR
				):
					marker.border_color.a = MARKER_HOVER_ALPHA.x
				else:
					marker.border_color.a = MARKER_HOVER_ALPHA.y
			if ui.selected_ship < friendly_ships.get_child_count():
				if friendly_ships.get_child(ui.selected_ship).target != null:
					if friendly_ships.get_child(ui.selected_ship).target == self:
						$Marker/Target.show()
					else:
						$Marker/Target.hide()
			# Marker labels setup
			$Marker/Info/Name.text = NAME_LABEL + ship_name
			$Marker/Info/Type.text = TYPE_LABEL + ui.SHIP_CODES[type]
			$Marker/Info/Hull.text = HULL_LABEL + str(hull)
			$Marker/Info/Status.text = Global.STATUS_MESSAGES[int(attacked)]
	
	scanned = false
	
	# General ship behaviour
	if active and not attacked:
		if type == Global.StarshipTypes.FIGHTER:
			# Start shooting!!!
			if Global.in_combat:
				# Fighters have three different ProgressBars for weapon reloading information
				for index in len(weapons):
					var this_timer: Timer = get_node("WeaponReload" + str(index + 1))
					if this_timer.is_stopped():
						this_timer.start()
					if this_timer.paused:
						this_timer.paused = false
					if ui.action_menu_showing:
						get_node("Marker/Reload" + str(index + 1)).show()
					get_node("Marker/Reload" + str(index + 1) + "/ProgressBar").value = (
							BAR_FACTOR - (
									(this_timer.time_left / this_timer.wait_time) * BAR_FACTOR)
							)
			else:
				$WeaponReload1.stop()
				$WeaponReload2.stop()
				$WeaponReload3.stop()
		if type == Global.StarshipTypes.SHIELD:
			# Should it reload its shields
			if shield_layers < level:
				if $ShieldReload.is_stopped():
					$ShieldReload.start()
				if ui.action_menu_showing:
					$Marker/Reload1.show()
				$Marker/Reload1/ProgressBar.value = BAR_FACTOR - (
						($ShieldReload.time_left / $ShieldReload.wait_time) * BAR_FACTOR
				)
			else:
				$ShieldReload.stop()
		if type == Global.StarshipTypes.INFILTRATION and $InfiltratingProcess.is_stopped():
			# Where we droppin' boys
			if Global.in_combat:
				if $InfiltrateReload.is_stopped():
					$InfiltrateReload.start()
			else:
				$InfiltrateReload.stop()
		if type == Global.StarshipTypes.REPAIR and ui.action_menu_showing:
			$Marker/Reload1.show()
			$Marker/Reload1/ProgressBar.value = BAR_FACTOR - (
					($RepairReload.time_left / $RepairReload.wait_time) * BAR_FACTOR
			)
		if type == Global.StarshipTypes.SCANNER and Global.in_combat:
			if target == null:
				new_target()
			target.scanned = true
		if type == Global.StarshipTypes.DRONE_COMMAND and Global.in_combat:
			# Only deploys drones once in battle
			if not drones_deployed:
				for drone in drones:
					if team == Global.Teams.FRIENDLY:
						Global.create_new_starship(
								Global.weapon_list[drone]["Ship type"],
								DEFAULT_NAME,
								id
						)
					elif team == Global.Teams.HOSTILE:
						Global.create_enemy_ship(
								Global.weapon_list[drone]["Ship type"],
								1,
								[0],
								id
						)
			else:
				for drone in all_drones.get_children():
					if drone.creator_id == id:
						drone.active = true
			drones_deployed = true
		if type == Global.StarshipTypes.FIGHTER_DRONE:
			if Global.in_combat:
				if $WeaponReload1.is_stopped():
					$WeaponReload1.start()
				if $WeaponReload1.paused:
					$WeaponReload1.paused = false
			else:
				hull = 0
		if type == Global.StarshipTypes.REPAIR or type == Global.StarshipTypes.REPAIR_DRONE:
			if target != null:
				if target.hull < target.hull_strength and $RepairReload.is_stopped():
					$RepairReload.start()
				elif target.hull >= target.hull_strength:
					$RepairReload.stop()
		if (
				type == Global.StarshipTypes.REPAIR_DRONE
				or (type == Global.StarshipTypes.REPAIR
						and team == Global.Teams.HOSTILE)
		):
			# Always searching for ships to repair
			if $RepairReload.is_stopped():
				new_target()
	else:
		# Hold fire for when reactivated
		# Can't use groups for this, otherwise it affects all starships
		for index in MAX_LEVEL:
			if get_node("WeaponReload" + str(index + 1)).time_left < RELOAD_HOLD:
				get_node("WeaponReload" + str(index + 1)).paused = true
		$RepairReload.stop()
		$ShieldReload.stop()
		$InfiltrateReload.stop()
		# Deactivate all "children" drones
		if type == Global.StarshipTypes.DRONE_COMMAND:
			for drone in all_drones.get_children():
				if drone.creator_id == id:
					drone.active = false
	
	# Do warping animations
	if jumping:
		# Jump in
		if jump_mode == 0 and team != Global.Teams.NEUTRAL:
			global_position.x = lerp(global_position.x, jump_destination, JUMP_LERP)
		# Warp out
		elif jump_mode == 1:
			global_position.x = lerp(global_position.x, warp_destination, JUMP_LERP)
			if global_position.x < warp_destination + 1.0 and team == Global.Teams.HOSTILE:
				main.enemy_ship_count -= 1
				queue_free()


# Warp
func _on_jump_delay_timeout() -> void:
	# The actual setting of the jump_mode variable has to be delayed
	$WarpSFX.stream = warp_sfx[jump_mode + 1]
	if jump_mode == 0:
		$WarpSFX.play()
		await get_tree().create_timer(WARP_OUT_SFX_DELAY).timeout
	jump_mode += 1
	if jump_mode == 0:
		await get_tree().create_timer(WARP_IN_SFX_DELAY).timeout
		$WarpSFX.play()


# Update all stats in data
func stats_update() -> void:
	var index: int = get_data_location()
	Global.fleet[index].ship_name = ship_name
	Global.fleet[index].level = level
	Global.fleet[index].hull_strength = hull_strength
	Global.fleet[index].hull = hull
	Global.fleet[index].agility = agility
	Global.fleet[index].weapons = weapons
	Global.fleet[index].drones = drones
	Global.fleet[index].active = active
	Global.stats_update()


# Begin the warping process and update stats
func begin_warp() -> void:
	if team == Global.Teams.FRIENDLY:
		# Update fleet data
		stats_update()
	$JumpDelay.start(randf() * JUMP_DELAY)


# Find a new target
func new_target(ship: int = 0) -> void:
	var target_set: bool = false
	# Target selection depends on various factors
	if type in Global.ENEMY_TARGETERS:
		if team == Global.Teams.FRIENDLY and hostile_ships.get_child_count() > 0:
			target = hostile_ships.get_child(ship)
		elif team == Global.Teams.HOSTILE and friendly_ships.get_child_count() > 0:
			target = friendly_ships.get_children().pick_random()
	
	elif type == Global.StarshipTypes.REPAIR:
		if team == Global.Teams.HOSTILE and hostile_ships.get_child_count() > 0:
			for potential_target in hostile_ships.get_children():
				if potential_target.hull < potential_target.hull_strength:
					target = potential_target
					target_set = true
			if not target_set:
				target = self
		elif team == Global.Teams.FRIENDLY and friendly_ships.get_child_count() > 0:
			target = friendly_ships.get_child(ship)
	
	elif type == Global.StarshipTypes.FIGHTER_DRONE:
		if team == Global.Teams.FRIENDLY and hostile_ships.get_child_count() > 0:
			target = hostile_ships.get_children().pick_random()
		elif team == Global.Teams.HOSTILE and friendly_ships.get_child_count() > 0:
			target = friendly_ships.get_children().pick_random()
	
	elif type == Global.StarshipTypes.REPAIR_DRONE:
		if team == Global.Teams.HOSTILE and hostile_ships.get_child_count() > 0:
			for potential_target in hostile_ships.get_children():
				if potential_target.hull < potential_target.hull_strength:
					target = potential_target
					target_set = true
			if not target_set:
				target = self
		elif (
				team == Global.Teams.FRIENDLY
				and friendly_ships.get_child_count() > 0
				and $RepairReload.is_stopped()
		):
			for potential_target in friendly_ships.get_children():
				if potential_target.hull < potential_target.hull_strength:
					target = potential_target
					target_set = true
			if not target_set:
				target = self


# Fire a weapon
func _weapon_fire(firing: int) -> void:
	var weapon_info: Dictionary = Global.weapon_list[weapons[firing]]
	if (
			target == null
			or is_drone
			or (targeting_strategy == Strategies.RANDOM
					and team == Global.Teams.HOSTILE)
	):
		new_target()
	create_new_projectile(weapon_info["Type"], weapon_info["Damage"])


# Create a new projectile upon firing a weapon
func create_new_projectile(projectile_type: int, damage: int) -> void:
	var new_projectile: Area3D = projectiles[projectile_type].instantiate()
	new_projectile.starting_position = global_position
	new_projectile.target = target
	new_projectile.damage = damage
	main.get_node("Projectiles").add_child(new_projectile)


# Get the location/index of this ship's data
func get_data_location() -> int:
	var index: int = 0
	for temp_ship in Global.fleet:
		if temp_ship.id == id:
			break
		index += 1
	return index


# Repair another ship
func _repair() -> void:
	if target == null:
		new_target()
	target.hull += REPAIR_VALUES[level]
	target.hull = clampi(target.hull, 0, target.hull_strength)


# Recover a shield layer
func _shield_up() -> void:
	shield_layers += 1
	shield_layers = clampi(shield_layers, 0, level)


# Infiltrate another ship
func _on_infiltrate_reload_timeout() -> void:
	if target == null:
		new_target()
	target.attacked = true
	target.get_node("UnderAttack").start()
	target.hull -= 1
	$InfiltratingProcess.start()


# Stop being attacked
func _on_under_attack_timeout() -> void:
	attacked = false


# Upgrade level and related stats
func upgrade() -> void:
	hull_strength += UPGRADES[type]["Hull" + str(level)]
	hull += UPGRADES[type]["Hull" + str(level)]
	agility += UPGRADES[type]["Agility" + str(level)]
	if type == Global.StarshipTypes.COMMAND_SHIP:
		Global.max_inventory += 1
	elif type == Global.StarshipTypes.FIGHTER and team == Global.Teams.FRIENDLY:
		weapons.append(0)
	elif type == Global.StarshipTypes.DRONE_COMMAND:
		drones.append(UPGRADES[type][str(level)])
	level += 1
	if team == Global.Teams.FRIENDLY:
		stats_update()


# Choose a new target
func _on_retarget_timeout() -> void:
	new_target()
	$Retarget.start(randf_range(RETARGET_DELAY.x, RETARGET_DELAY.y))
