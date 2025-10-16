extends Node3D


var type: int = 0
var palettes: Array[Array] = [
	[
		preload("res://alliance_primary.tres").duplicate(),
		preload("res://alliance_secondary.tres").duplicate(),
		preload("res://alliance_tertiary.tres").duplicate(),
		preload("res://alliance_accent.tres").duplicate()
	],
	[
		preload("res://pirate_yellow_primary.tres").duplicate(),
		preload("res://pirate_yellow_secondary.tres").duplicate(),
		preload("res://pirate_yellow_tertiary.tres").duplicate(),
		preload("res://pirate_yellow_accent.tres").duplicate()
	],
	[
		preload("res://pirate_green_primary.tres").duplicate(),
		preload("res://pirate_green_secondary.tres").duplicate(),
		preload("res://pirate_green_tertiary.tres").duplicate(),
		preload("res://pirate_green_accent.tres").duplicate()
	],
	[
		preload("res://pirate_purple_primary.tres").duplicate(),
		preload("res://pirate_purple_secondary.tres").duplicate(),
		preload("res://pirate_purple_tertiary.tres").duplicate(),
		preload("res://pirate_purple_accent.tres").duplicate()
	],
]


func _ready() -> void:
	# Check each part and see which material needs to be applied
	for part in get_children():
		part.mesh.material = palettes[type][int(String(part.name)[-1])]
