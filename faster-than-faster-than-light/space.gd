extends Node3D


@export var bg_star: PackedScene
@export var bg_nebula: PackedScene

var system_types: Array[int] = [1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 3]
var star_colours: Array[Color] = [Color(1, 1, 0), Color(1, 0.3, 0), Color(1, 0.1, 0), Color(1, 1, 1), Color(0.6, 0.6, 1), Color(0.3, 0.3, 1), Color(0.1, 0.1, 1)]


func _ready() -> void:
	for i in system_types.pick_random():
		var z: float = randf_range(-3000, -300)
		var x: float = randf_range(z * -1.25, z * 1.25)
		var y: float = randf_range(z / 0.8, z / -2.3)
		var colour = star_colours.pick_random()
		$Background.get_node("MainStar" + str(i + 1)).mesh.material.color = colour
		$Background.get_node("MainStar" + str(i + 1)).mesh.material.emission = colour
		$Background.get_node("MainStar" + str(i + 1)).mesh.radius = randf_range(75, 180)
		$Background.get_node("MainStar" + str(i + 1)).mesh.height = $Background.get_node("MainStar" + str(i + 1)).mesh.radius * 2
		$Background.get_node("MainStar" + str(i + 1)).position = Vector3(x, y, z)
	var nebula_pos: Vector3
	var nebula_colour: Color = Color(randf_range(0.1, 1.0), randf_range(0.1, 1.0), randf_range(0.1, 1.0))
	for i in randi_range(1, 20):
		nebula_pos = Vector3(randf_range(-2000, 2000), randf_range(-1000, 800), randf_range(-2000, -800))
		nebula_colour += Color(randf_range(-0.1, 0.1), randf_range(-0.1, 0.1), randf_range(-0.1, 0.1))
		if randi_range(0, 40) == 4:
			for j in randi_range(50, 300):
				var new_nebula = bg_nebula.instantiate()
				new_nebula.position = nebula_pos
				new_nebula.mesh.material.color = Color(nebula_colour, 0.01)
				new_nebula.mesh.material.emission = Color(nebula_colour)
				new_nebula.mesh.radius = randf_range(20, 50)
				new_nebula.mesh.height = new_nebula.mesh.radius * 2
				nebula_pos += Vector3(randf_range(-75, 75), randf_range(-100, 100), randf_range(-100, 100))
				$Background.add_child(new_nebula)
		else:
			for j in randi_range(1, 25):
				var new_nebula = bg_nebula.instantiate()
				new_nebula.position = nebula_pos
				new_nebula.mesh.material.albedo_color = Color(nebula_colour, 0.01)
				new_nebula.mesh.material.emission = Color(nebula_colour)
				new_nebula.mesh.radius = randf_range(20, 50)
				new_nebula.mesh.height = new_nebula.mesh.radius * 2
				nebula_pos += Vector3(randf_range(-50, 50), randf_range(-50, 50), randf_range(-50, 50))
				$Background.add_child(new_nebula)
	for i in randi_range(400, 1200):
		var new_star = bg_star.instantiate()
		new_star.mesh.radius = randf_range(0.6, 1.5)
		new_star.mesh.height = new_star.mesh.radius * 2
		new_star.position = Vector3(randf_range(-1500, 1500), randf_range(-1500, 1500), randf_range(-1500, -200))
		$Background.add_child(new_star)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug_quit"):
		get_tree().quit()
