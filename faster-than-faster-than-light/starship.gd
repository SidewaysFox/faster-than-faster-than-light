class_name Starship extends Node3D


@export_category("Properties")
## The starship's ID, used to identify it in data storage
@export var id: int = 0
## What team the starship is on
@export var team: int = 0
# -1: Hostile
# 0: Neutral
# 1: Friendly
## The starship's type
@export var type: int = 0
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
@export var alignment: int = 0
# 0: Federation
# 1: Civilian
# 2: Rebel
# 3: Pirate
## The starship's name
@export var ship_name: String = "Starship"
## The starship's current level
@export var level: int = 1
## The starship's maximum hull points
@export var hull_strength: int = 10
## The starship's currently active weapons
@export var weapons: Array[int] = []
## Ship meshes
@export var meshes: Array[PackedScene] = []

# Miscellaneous stats
var kills: int = 0
var total_hull_damage: int = 0

# Variables
@onready var main: Node = get_node("/root/Space")
var hull: int = 10
var target: Node
var jumping: bool = true
var jump_mode: int = -1
var jump_destination: float
var warp_destination: float
var spawn_location: Vector3


func _ready() -> void:
	# Apply appropriate mesh
	var new_mesh: Node = meshes[type].instantiate()
	new_mesh.type = alignment
	add_child(new_mesh)
	# Starting location based on team
	if team != 0:
		global_position = Vector3(-2000 * team, randf_range(-60, 60), randf_range(-100, 0))
		rotation.y = (PI / 2) - ((PI * team) / 2)
	else:
		global_position = Vector3(randf_range(50, 50), randf_range(-25, 25), randf_range(-10, -150))
		jumping = false
	jump_destination = randf_range(-120, -50) * team
	warp_destination = -global_position.x
	$JumpDelay.start(1 + (randf() * 2))


func _process(delta: float) -> void:
	# Do jumping animations
	if jumping:
		if jump_mode == 0 and team != 0:
			global_position.x = lerp(global_position.x, jump_destination, 0.1)
		elif jump_mode == 1:
			global_position.x = lerp(global_position.x, warp_destination, 0.1)


func _on_jump_delay_timeout() -> void:
	jump_mode += 1


func begin_warp() -> void:
	# Update fleet data
	Global.fleet[id].ship_name = ship_name
	Global.fleet[id].level = level
	Global.fleet[id].hull_strength = hull_strength
	Global.fleet[id].weapons = weapons
	$JumpDelay.start(randf() * 2)


func _on_targeting_delay_timeout() -> void:
	# Choose a target
	if team == 1 and len(main.get_node("HostileShips").get_children()) > 0:
		target = main.get_node("HostileShips").get_child(0)
	elif team == -1:
		target = main.get_node("FriendlyShips").get_child(0)
