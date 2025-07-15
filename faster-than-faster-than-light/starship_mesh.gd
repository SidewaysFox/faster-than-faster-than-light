extends Node3D


var type: int = 0
var palettes: Array[Array] = [
	[preload("res://federation_primary.tres").duplicate(), preload("res://federation_secondary.tres").duplicate(), preload("res://federation_tertiary.tres").duplicate(), preload("res://federation_accent.tres").duplicate()],
	[],
	[],
	[preload("res://pirate_primary.tres").duplicate(), preload("res://pirate_secondary.tres").duplicate(), preload("res://pirate_tertiary.tres").duplicate(), preload("res://pirate_accent.tres").duplicate()],
]
#var palettes: Array[Array] = [ # Main, accent
	#[Color8(200, 200, 200), Color8(160, 160, 160), Color8(255, 80, 0), Color8(120, 120, 120)],
	#[],
	#[],
	#[Color8(50, 0, 140), Color8(60, 20, 160), Color8(255, 70, 100)],
#]


func _ready() -> void:
	print("\nmesh type " + str(type))
	for part in get_children():
		print(part.name)
		part.mesh.material = palettes[type][int(String(part.name)[-1])]
		print(part.mesh.material.albedo_color)
		print(part.mesh.material.emission)
