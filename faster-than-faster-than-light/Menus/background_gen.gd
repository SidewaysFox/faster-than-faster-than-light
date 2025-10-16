extends Node3D


@export var bg_nebula: PackedScene
var system_types: Array[int] = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 3]
var star_colours: Array[Color] = [
	Color(1, 1, 0),
	Color(1, 0.3, 0),
	Color(1, 0.1, 0),
	Color(0.9, 0.9, 0.9),
	Color(0.6, 0.6, 1),
	Color(0.3, 0.3, 1),
	Color(0.1, 0.1, 1)
	]
var main_star_count: String
var bg_object_rotation: float = 5.0

const BG_STARS_SEED: Vector2 = Vector2(0.01, 100.0)
const BG_STARS_PROB: Vector2 = Vector2(0.91, 1.0)
const BG_STARS_SIZE: Vector2 = Vector2(50.0, 120.0)
const RADIUS_RANGE: Vector2 = Vector2(40.0, 250.0)
const HEIGHT_FACTOR: float = 2.0
const STAR_POS_Z: Vector2 = Vector2(-2500, -300)
const STAR_X_FACTOR: float = 1.1
const STAR_Y_FACTOR: Vector2 = Vector2(0.8, -2.3)
const NEB_COL: Vector2 = Vector2(0.1, 1.0)
const NEB_ALPHA: Vector2 = Vector2(0.04, 0.2)
const NEB_COUNT: Vector2i = Vector2i(1, 25)
const NEB_POS_X: Vector2 = Vector2(-2000, 2000)
const NEB_POS_Y: Vector2 = Vector2(-1000, 800)
const NEB_POS_Z: Vector2 = Vector2(-2000, -800)
const NEB_RADIUS: Vector2 = Vector2(20, 50)
const NEB_POS_SHIFT: float = 50.0
const NEB_COL_SHIFT: float = 0.1
const NEB_ALPHA_SHIFT: float = 0.05
const LARGE_NEB_CHANCE: int = 30
const LARGE_NEB_SIZE: Vector2i = Vector2i(50, 300)
const SMALL_NEB_SIZE: Vector2i = Vector2i(1, 20)
const STAR_RENDER_DISTANCE: float = 3500.0


func _ready() -> void:
	# Begin playing music from where it left off in the previous menu
	$Music.play(Global.menu_music_progress)
	# Pass information to the BGStar GLSL script
	$BGStars.material_override.set_shader_parameter("seed",
			randf_range(BG_STARS_SEED.x, BG_STARS_SEED.y))
	$BGStars.material_override.set_shader_parameter("prob",
			randf_range(BG_STARS_PROB.x, BG_STARS_PROB.y))
	$BGStars.material_override.set_shader_parameter("size",
			randf_range(BG_STARS_SIZE.x, BG_STARS_SIZE.y))
	# Establish this system's star(s)
	main_star_count = str(system_types.pick_random())
	for star in get_tree().get_nodes_in_group(main_star_count):
		# Set star colour
		var colour: Color = star_colours.pick_random()
		star.mesh.material.albedo_color = colour
		star.mesh.material.emission = colour
		# Set star size
		var radius: float = randf_range(RADIUS_RANGE.x, RADIUS_RANGE.y)
		star.mesh.radius = radius
		star.mesh.height = radius * HEIGHT_FACTOR
		# Set positioning
		var star_position: Vector3 = star_reposition()
		var not_colliding: int = 1
		# Make sure it's not colliding with any other stars
		while not_colliding == get_tree().get_node_count_in_group(main_star_count):
			for other_star in get_tree().get_nodes_in_group(main_star_count):
				if (
						other_star != star
						and star_position.distance_to(other_star.position)
						< star.mesh.radius + other_star.mesh.radius
				):
					star_position = star_reposition()
				else:
					not_colliding += 1
		star.position = star_position
		star.mesh.material.emission_texture.noise.seed = randi()
	# Create nebulae
	var nebula_pos: Vector3
	var nebula_colour: Color = Color(
			randf_range(NEB_COL.x, NEB_COL.y),
			randf_range(NEB_COL.x, NEB_COL.y),
			randf_range(NEB_COL.x, NEB_COL.y),
			randf_range(NEB_ALPHA.x, NEB_ALPHA.y)
	)
	for nebula in randi_range(NEB_COUNT.x, NEB_COUNT.y):
		# Set position
		nebula_pos = Vector3(
				randf_range(NEB_POS_X.x, NEB_POS_X.y),
				randf_range(NEB_POS_Y.x, NEB_POS_Y.y),
				randf_range(NEB_POS_Z.x, NEB_POS_Z.y)
		)
		# Set colour
		nebula_colour += Color(
				randf_range(-NEB_COL_SHIFT, NEB_COL_SHIFT),
				randf_range(-NEB_COL_SHIFT, NEB_COL_SHIFT),
				randf_range(-NEB_COL_SHIFT, NEB_COL_SHIFT),
				randf_range(-NEB_ALPHA_SHIFT, NEB_ALPHA_SHIFT)
		)
		nebula_colour.a = clamp(nebula_colour.a, NEB_ALPHA.x, NEB_ALPHA.y)
		# Big or small nebula
		if randi_range(0, LARGE_NEB_CHANCE) == 0:
			# Big
			for cloud in randi_range(LARGE_NEB_SIZE.x, LARGE_NEB_SIZE.y):
				var new_nebula: MeshInstance3D = bg_nebula.instantiate()
				new_nebula.position = nebula_pos
				new_nebula.mesh.material.albedo_color = nebula_colour
				new_nebula.mesh.material.emission = nebula_colour
				new_nebula.mesh.radius = randf_range(NEB_RADIUS.x, NEB_RADIUS.y)
				new_nebula.mesh.height = new_nebula.mesh.radius * HEIGHT_FACTOR
				$Background.add_child(new_nebula)
				nebula_pos += Vector3(
						randf_range(-NEB_POS_SHIFT, NEB_POS_SHIFT),
						randf_range(-NEB_POS_SHIFT, NEB_POS_SHIFT),
						randf_range(-NEB_POS_SHIFT, NEB_POS_SHIFT)
				)
		else:
			# Small
			for cloud in randi_range(SMALL_NEB_SIZE.x, SMALL_NEB_SIZE.y):
				var new_nebula: MeshInstance3D = bg_nebula.instantiate()
				new_nebula.position = nebula_pos
				new_nebula.mesh.material.albedo_color = nebula_colour
				new_nebula.mesh.material.emission = nebula_colour
				new_nebula.mesh.radius = randf_range(NEB_RADIUS.x, NEB_RADIUS.y)
				new_nebula.mesh.height = new_nebula.mesh.radius * HEIGHT_FACTOR
				$Background.add_child(new_nebula)
				nebula_pos += Vector3(
						randf_range(-NEB_POS_SHIFT, NEB_POS_SHIFT),
						randf_range(-NEB_POS_SHIFT, NEB_POS_SHIFT), 
						randf_range(-NEB_POS_SHIFT, NEB_POS_SHIFT)
				)


func _process(delta: float) -> void:
	# UI stuff
	if Input.is_action_just_pressed("debug quit"):
		get_tree().quit()
	if Input.is_action_pressed("hide ui"):
		$CanvasLayer.hide()
	else:
		$CanvasLayer.show()
	
	# Rotate background objects
	for child in $Background.get_children():
		child.rotation_degrees.y += bg_object_rotation * delta
	
	# Restart music if it ends
	if not $Music.playing:
		Global.menu_music_progress = 0.0
		$Music.play()


func star_reposition() -> Vector3:
	var x: float
	var y: float
	var z: float
	z = randf_range(STAR_POS_Z.x, STAR_POS_Z.y)
	# X and Y are set relative to the Z value in an attempt to keep it on screen
	x = randf_range(z * -STAR_X_FACTOR, z * STAR_X_FACTOR)
	y = randf_range(z / STAR_Y_FACTOR.x, z / STAR_Y_FACTOR.y)
	# Make sure the star is within rendering bounds
	while Vector3(x, y, z).distance_to(Vector3.ZERO) > STAR_RENDER_DISTANCE:
		z = randf_range(STAR_POS_Z.x, STAR_POS_Z.y)
		x = randf_range(z * -STAR_X_FACTOR, z * STAR_X_FACTOR)
		y = randf_range(z / STAR_Y_FACTOR.x, z / STAR_Y_FACTOR.y)
	return Vector3(x, y, z)
