class_name Starship extends Node3D


@export_category("Properties")
## What team the starship is on - 0 is neutral, 1 is friendly, 2 is hostile
@export var team: int = 0
## The starship's type
@export var type: int = 0
## The starship's name
@export var ship_name: String = "Starship"
## The starship's maximum hull points
@export var hull_strength: int = 10
## The starship's currently active weapons
@export var weapons: Array[int] = []
## The maximum number of resources the ship can carry
@export var storage: int = 50

# Variables
var hull: int = 10
var resources: int = 0
var jumping: bool = true
var jump_mode: int = -1
var jump_destination: Vector3

# Misc stats
var kills: int = 0
var total_hull_damage: int = 0


func _ready() -> void:
	if team != 0:
		global_position = Vector3(-2000 * team, randf_range(-200, 200), randf_range(-200, 200))
	else:
		global_position = Vector3(randf_range(50, 50), randf_range(-25, 25), randf_range(-10, -150))
	jump_destination = Vector3(randf_range(-170, -50) * team, randf_range(-60, 60), randf_range(25, -100))
	$JumpDelay.start(randf() * 2)


func _process(delta: float) -> void:
	if jumping:
		if jump_mode == 0 and team != 0:
			global_position = lerp(global_position, jump_destination, 0.1)


func _on_jump_delay_timeout() -> void:
	jump_mode += 1
