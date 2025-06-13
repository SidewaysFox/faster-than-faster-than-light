class_name Starship extends Node3D


@export_category("Properties")
## What team the starship is on - 0 is neutral, 1 is friendly, 2 is hostile
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
# 9: Drone infiltration
#10: Drone repair
## The starship's species of origin
@export var species: int = 0
# -1: Unmanned
# 0: Human
## The starship's name
@export var ship_name: String = "Starship"
## The starship's maximum hull points
@export var hull_strength: int = 10
## The starship's currently active weapons
@export var weapons: Array[int] = []
## Ship meshes
@export var meshes: Array[PackedScene] = []

# Variables
var hull: int = 10
var target: int = -1
var jumping: bool = true
var jump_mode: int = -1
var jump_destination: Vector3

# Misc stats
var kills: int = 0
var total_hull_damage: int = 0


func _ready() -> void:
	add_child(meshes[type].instantiate())
	if team != 0:
		global_position = Vector3(-2000 * team, randf_range(-200, 200), randf_range(-200, 200))
	else:
		global_position = Vector3(randf_range(50, 50), randf_range(-25, 25), randf_range(-10, -150))
	jump_destination = Vector3(randf_range(-120, -50) * team, randf_range(-60, 60), randf_range(-100, 0))
	$JumpDelay.start(randf() * 2)


func _process(delta: float) -> void:
	if jumping:
		if jump_mode == 0 and team != 0:
			global_position = lerp(global_position, jump_destination, 0.1)


func _on_jump_delay_timeout() -> void:
	jump_mode += 1
