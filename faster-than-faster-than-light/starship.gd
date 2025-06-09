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

# Misc stats
var kills: int = 0
var total_hull_damage: int = 0


func _process(delta: float) -> void:
	pass
