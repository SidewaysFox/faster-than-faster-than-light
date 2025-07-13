extends Node3D


var type: int = 0
var palettes: Array[Array] = [ # Main, accent
	[Color8(200, 200, 200), Color8(160, 160, 160), Color8(255, 80, 0), Color8(120, 120, 120)],
	[],
	[],
	[Color8(50, 0, 140), Color8(60, 20, 160), Color8(255, 70, 100)],
]


func _ready() -> void:
	print("mesh type " + str(type))
	for part in get_children():
		if "Accent" in part.name:
			part.mesh.material.albedo_color = palettes[type][2]
			part.mesh.material.emission = palettes[type][2]
			print(part.mesh.material.albedo_color)
		elif "Hull" in part.name:
			part.mesh.material.albedo_color = palettes[type][0]
			part.mesh.material.emission = Color(1, 1, 1)
		elif "Wing" in part.name:
			part.mesh.material.albedo_color = palettes[type][1]
			part.mesh.material.emission = Color(1, 1, 1)
		elif "Bridge" in part.name:
			part.mesh.material.albedo_color = palettes[type][3]
			part.mesh.material.emission = Color(1, 1, 1)
