extends Node3D


@export var bg_star: PackedScene
@export var bg_nebula: PackedScene


func _ready() -> void:
	var z = randf_range(-4000, -400)
	var x = randf_range(z * -1.25, z * 1.25)
	var y = randf_range(z * 1.2, z * -0.5)
	$Background/MainStar.position = Vector3(x, y, z)
	var nebula_pos: Vector3
	var nebula_colour: Color
	for i in randi_range(1, 20):
		nebula_pos = Vector3(randf_range(-2000, 2000), randf_range(-1000, 800), randf_range(-2000, -800))
		nebula_colour = Color(randf_range(0.1, 1.0), randf_range(0.1, 1.0), randf_range(0.1, 1.0))
		if randi_range(0, 40) == 4:
			print("yes")
			for j in randi_range(100, 300):
				var new_nebula = bg_nebula.instantiate()
				new_nebula.position = nebula_pos
				new_nebula.mesh.material.color = Color(nebula_colour, 0.01)
				new_nebula.mesh.material.emission = Color(nebula_colour)
				nebula_pos += Vector3(randf_range(-40, 40), randf_range(-40, 40), randf_range(-40, 40))
				$Background.add_child(new_nebula)
		else:
			for j in randi_range(1, 25):
				var new_nebula = bg_nebula.instantiate()
				new_nebula.position = nebula_pos
				new_nebula.mesh.material.color = Color(nebula_colour, 0.01)
				new_nebula.mesh.material.emission = Color(nebula_colour)
				nebula_pos += Vector3(randf_range(-50, 50), randf_range(-50, 50), randf_range(-50, 50))
				$Background.add_child(new_nebula)
	for i in randi_range(800, 1600):
		var new_star = bg_star.instantiate()
		new_star.position = Vector3(randf_range(-1500, 1500), randf_range(-1500, 1500), randf_range(-1500, -200))
		$Background.add_child(new_star)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug_quit"):
		get_tree().quit()
