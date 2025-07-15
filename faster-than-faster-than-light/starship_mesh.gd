extends Node3D


var type: int = 0
var palettes: Array[Array] = [
	[preload("res://federation_primary.tres").duplicate(), preload("res://federation_secondary.tres").duplicate(), preload("res://federation_tertiary.tres").duplicate(), preload("res://federation_accent.tres").duplicate()],
	[],
	[],
	[preload("res://pirate_primary.tres").duplicate(), preload("res://pirate_secondary.tres").duplicate(), preload("res://pirate_tertiary.tres").duplicate(), preload("res://pirate_accent.tres").duplicate()],
]


func _ready() -> void:
	for part in get_children():
		part.mesh.material = palettes[type][int(String(part.name)[-1])]
