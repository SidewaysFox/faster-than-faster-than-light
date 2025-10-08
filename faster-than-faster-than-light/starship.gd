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
# 7: Drone command ship
# 8: Drone fighter
# 9: Drone repair
## The starship's alignment
@export var alignment: int
# 0: Federation
# 1: Civilian
# 2: Rebel
# 3: Pirate
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
@export var drone_slots: Array[int] = [1]
@export_category("Misc")
## Ship meshes
@export var meshes: Array[PackedScene] = []
## Projectiles
@export var projectiles: Array[PackedScene] = []

# Miscellaneous stats
var kills: int = 0
var total_hull_damage: int = 0

# Variables
@onready var main: Node = get_node("/root/Space")
@onready var ui: Node = get_node("/root/Space/CanvasLayer/UserInterface")
@export_category("Bugfixing")
@export var hull: int # WHY DOES THIS NEED TO BE EXPORTED
var target: Node
var jumping: bool = true
var jump_mode: int = -1
var jump_destination: float
var warp_destination: float
var spawn_location: Vector3
var marker: StyleBoxFlat
var status: int
var active: bool = true
var shield_layers: int
var attacked: bool = false
var scanned: bool = false
var set_level: int

const INFILTRATE_RECHARGE: float = 16.0
const INFILTRATE_UPGRADE: float = 3.5
const REPAIR_TIME: float = 15.0
const REPAIR_UPGRADE: float = 3.0

const STATUS_MESSAGES: Array[String] = ["STATUS: OK", "STATUS: UNDER ATTACK"]


func _ready() -> void:
	# Apply appropriate mesh
	var new_mesh: Node = meshes[type].instantiate()
	new_mesh.type = alignment
	add_child(new_mesh)
	
	marker = $Marker/Selection.get_theme_stylebox("panel")
	
	if ship_name == "Starship" and team == 1:
		ship_name = Global.possible_names.pop_at(randi_range(0, len(Global.possible_names) - 1))
	elif team != 1:
		ship_name = "PIRATE"
		for l in set_level:
			upgrade()
	
	# Starting location based on team
	if team != 0:
		global_position = Vector3(-2000 * team, randf_range(-60, 60), randf_range(-100, 0))
		rotation.y = (PI / 2) - ((PI * team) / 2)
		
		if team == 1:
			marker.border_color = Color.WHITE
		else:
			marker.border_color = Color.DARK_RED
	else:
		global_position = Vector3(randf_range(50, 50), randf_range(-25, 25), randf_range(-10, -150))
		jumping = false
	jump_destination = randf_range(-120, -50) * team
	warp_destination = -global_position.x
	$JumpDelay.start(1 + (randf() * 2))
	
	if type == 1:
		var index: int = 1
		for weapon_id in weapons:
			get_node("WeaponReload" + str(index)).wait_time = Global.weapon_list[weapon_id]["Reload time"]
			index += 1
	elif type == 2:
		shield_layers = level
	elif type == 3:
		$InfiltrateReload.wait_time = INFILTRATE_RECHARGE - (level * INFILTRATE_UPGRADE)
	elif type == 4:
		$RepairReload.wait_time = REPAIR_TIME - (level * REPAIR_UPGRADE)


func _process(_delta: float) -> void:
	if hull <= 0:
		if team == 1:
			Global.fleet.remove_at(_get_data_location())
		queue_free()
	
	var hover_alpha: int
	$Marker/Reload1.hide()
	$Marker/Reload2.hide()
	$Marker/Reload3.hide()
	if team == 1:
		if ui.selected_ship == get_index():
			$Marker.modulate.a = 1.0
		else:
			$Marker.modulate.a = 0.4
		if ui.hovered_ship == get_index() or (ui.hovered_target == get_index() and ui.targeting_mode == 4):
			hover_alpha = 255
		else:
			hover_alpha = 160
	elif team == -1:
		if ui.hovered_target == get_index() and ui.targeting_mode != 4:
			hover_alpha = 255
		else:
			hover_alpha = 160
	if ui.selected_ship == get_index() and team == 1:
		marker.border_color = Color8(0, 191, 255, hover_alpha)
	else:
		marker.border_color = Color8(255, 255, 255, hover_alpha)
	if ui.selected_ship < main.get_node("FriendlyShips").get_child_count():
		if main.get_node("FriendlyShips").get_child(ui.selected_ship).target != null:
			if main.get_node("FriendlyShips").get_child(ui.selected_ship).target == self:
				$Marker/Target.show()
			else:
				$Marker/Target.hide()
	$Marker/Info/Name.text = "NAME: " + ship_name
	$Marker/Info/Type.text = "TYPE: " + ui.SHIP_CODES[type]
	$Marker/Info/Hull.text = "HULL: " + str(hull)
	$Marker/Info/Status.text = STATUS_MESSAGES[int(attacked)]
	
	if ui.action_menu_showing and (team == 1 or scanned):
		$Marker.show()
	else:
		$Marker.hide()
	
	scanned = false
	
	if active and not attacked:
		if type == 1:
			# Start shooting!!!
			if Global.in_combat:
				for i in len(weapons):
					var this_timer: Node = get_node("WeaponReload" + str(i + 1))
					if this_timer.is_stopped():
						this_timer.start()
					if this_timer.paused:
						this_timer.paused = false
					if ui.action_menu_showing:
						get_node("Marker/Reload" + str(i + 1)).show()
					get_node("Marker/Reload" + str(i + 1) + "/ProgressBar").value = 100 - ((this_timer.time_left / this_timer.wait_time) * 100)
			else:
				$WeaponReload1.stop()
				$WeaponReload2.stop()
				$WeaponReload3.stop()
		if type == 2:
			if shield_layers < level:
				if $ShieldReload.is_stopped():
					$ShieldReload.start()
				if ui.action_menu_showing:
					$Marker/Reload1.show()
				$Marker/Reload1/ProgressBar.value = 100 - (($ShieldReload.time_left / $ShieldReload.wait_time) * 100)
			else:
				$ShieldReload.stop()
		if type == 3 and $InfiltratingProcess.is_stopped():
			if Global.in_combat:
				if $InfiltrateReload.is_stopped():
					$InfiltrateReload.start()
			else:
				$InfiltrateReload.stop()
		if type == 4 and target != null:
			if ui.action_menu_showing:
				$Marker/Reload1.show()
			$Marker/Reload1/ProgressBar.value = 100 - (($RepairReload.time_left / $RepairReload.wait_time) * 100)
			if target.hull < target.hull_strength and $RepairReload.is_stopped():
				$RepairReload.start()
			elif target.hull >= target.hull_strength:
				$RepairReload.stop()
		if type == 5 and Global.in_combat:
			if target == null:
				new_target()
			target.scanned = true
	else:
		for num in len(weapons):
			if get_node("WeaponReload" + str(num + 1)).time_left < 0.1:
				get_node("WeaponReload" + str(num + 1)).paused = true
		$RepairReload.stop()
		$ShieldReload.stop()
		$InfiltrateReload.stop()
	
	# Do jumping animations
	if jumping:
		if jump_mode == 0 and team != 0:
			global_position.x = lerp(global_position.x, jump_destination, 0.1)
		elif jump_mode == 1:
			global_position.x = lerp(global_position.x, warp_destination, 0.1)


func _on_jump_delay_timeout() -> void:
	jump_mode += 1


func stats_update() -> void:
	var index: int = _get_data_location()
	Global.fleet[index].ship_name = ship_name
	Global.fleet[index].level = level
	Global.fleet[index].hull_strength = hull_strength
	Global.fleet[index].hull = hull
	Global.fleet[index].agility = agility
	Global.fleet[index].weapons = weapons
	Global.fleet[index].active = active
	Global.stats_update()


func begin_warp() -> void:
	# Update fleet data
	stats_update()
	$JumpDelay.start(randf() * 2)


func new_target(ship: int = 0) -> void:
	# Choose a target
	if type == 1 or type == 3 or type == 5:
		if team == 1 and main.get_node("HostileShips").get_child_count() > 0:
			target = main.get_node("HostileShips").get_child(ship)
		elif team == -1 and main.get_node("FriendlyShips").get_child_count() > 0:
			target = main.get_node("FriendlyShips").get_children().pick_random()
	elif type == 4:
		if team == -1 and main.get_node("HostileShips").get_child_count() > 0:
			target = main.get_node("HostileShips").get_children().pick_random()
		elif team == 1 and main.get_node("FriendlyShips").get_child_count() > 0:
			target = main.get_node("FriendlyShips").get_child(ship)


func _weapon_fire(firing: int) -> void:
	var weapon_info: Dictionary = Global.weapon_list[weapons[firing]]
	if target == null:
		new_target()
	_new_projectile(weapon_info["Type"], weapon_info["Damage"])


func _new_projectile(projectile_type: int, damage: int) -> void:
	var new_projectile: Node = projectiles[projectile_type].instantiate()
	new_projectile.starting_position = global_position
	new_projectile.target = target
	new_projectile.damage = damage
	main.get_node("Projectiles").add_child(new_projectile)


func _get_data_location() -> int:
	var index: int = 0
	for temp_ship in Global.fleet:
		if temp_ship.id == id:
			break
		index += 1
	return index


func _repair() -> void:
	if target == null:
		new_target()
	if level < 3:
		target.hull += 1
	else:
		target.hull += 2
	target.hull = clampi(target.hull, 0, target.hull_strength)


func _shield_up() -> void:
	shield_layers += 1
	shield_layers = clampi(shield_layers, 0, level)


func _on_infiltrate_reload_timeout() -> void:
	if target == null:
		new_target()
	target.attacked = true
	target.get_node("UnderAttack").start()
	target.hull -= 1


func _on_under_attack_timeout() -> void:
	attacked = false


func upgrade() -> void:
	# I genuinely cannot think of a better way to do this
	if type == 0:
		hull_strength += 5
		hull += 5
		agility += 0.05
		Global.max_inventory += 1
	elif type == 1:
		if level == 1:
			hull_strength += 2
			hull += 2
			agility += 0.05
		elif level == 2:
			hull_strength += 4
			hull += 4
			agility += 0.1
		weapons.append(0)
	elif type == 2:
		agility += 0.05
		if level == 1:
			hull_strength += 2
			hull += 2
		elif level == 2:
			hull_strength += 3
			hull += 3
	elif type == 3:
		agility += 0.05
		if level == 1:
			hull_strength += 2
			hull += 2
		elif level == 2:
			hull_strength += 5
			hull += 5
	elif type == 4:
		if level == 1:
			hull_strength += 1
			hull += 1
			agility += 0.05
		elif level == 2:
			hull_strength += 2
			hull += 2
	elif type == 5:
		hull_strength += 1
		hull += 1
		if level == 1:
			agility += 0.05
		elif level == 2:
			agility += 0.1
	elif type == 6:
		agility += 0.05
		if level == 1:
			hull_strength += 1
			hull += 1
		elif level == 2:
			hull_strength += 2
			hull += 2
	elif type == 7:
		hull_strength += 4
		hull += 4
		if level == 1:
			drone_slots.append(0)
		elif level == 2:
			drone_slots.append_array([0, 0])
	level += 1
	if team == 1:
		stats_update()
