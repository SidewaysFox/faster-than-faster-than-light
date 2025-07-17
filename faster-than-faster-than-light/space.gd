extends Node3D


@export var bg_nebula: PackedScene
@export var starship: PackedScene
var system_types: Array[int] = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 3]
var star_colours: Array[Color] = [Color(1, 1, 0), Color(1, 0.3, 0), Color(1, 0.1, 0), Color(1, 1, 1), Color(0.6, 0.6, 1), Color(0.3, 0.3, 1), Color(0.1, 0.1, 1)]
var main_star_count: int
var system_properties: Array = []
var system_stage: String
var star_proximity: bool = false
var warp_charge: float = 0.0

var pirate_fleets: Dictionary = {
	"start": [
		[1, 1],
		#[1, 2],
		#[1, 3],
		#[1, 4],
		#[1, 5],
		[1, 6],
		#[1, 7],
		#[3, 3],
		[1, 1, 1],
		#[1, 1, 2],
		#[1, 1, 3],
		#[1, 1, 4],
		#[1, 1, 5],
		[1, 1, 6],
		#[1, 3, 3],
	],
	"early": [
		[1, 1, 1],
		[1, 1, 6],
		#[1, 1, 1, 4],
		#[1, 1, 2, 4],
		[1, 1, 1, 1],
		[1, 1, 1, 6],
		[1, 1, 6, 6],
	],
	"middle": [
		[1, 1, 1, 1, 1],
		#[1, 1, 1, 4, 4],
		[1, 1, 1, 1, 6],
		#[1, 1, 2, 4],
		[1, 1, 1, 1, 1, 1],
		[1, 1, 1, 1, 1, 6],
	],
	"late": [
		#[1, 1, 1, 2, 2, 2, 3],
		[1, 1, 1, 1, 1, 1, 1, 1],
		#[1, 1, 1, 2, 2, 2, 3, 4],
		#[1, 1, 2, 3, 3, 3, 3, 4],
	]
}


func _ready() -> void:
	# TODO: tesselating noise map with shader
	# TODO: add star glow
	
	# Spawn fleet
	if not Global.initilising:
		for ship in Global.fleet:
			$FriendlyShips.add_child(ship.duplicate())
	
	if Global.galaxy_data[Global.current_system]["position"].x > 2400:
		system_stage = "late"
	elif Global.galaxy_data[Global.current_system]["position"].x > 1600:
		system_stage = "middle"
	elif Global.galaxy_data[Global.current_system]["position"].x > 800:
		system_stage = "early"
	else:
		system_stage = "start"
	
	# Pass information to the BGStar GLSL script
	$BGStars.material_override.set_shader_parameter("seed", randf_range(0.01, 100.0))
	$BGStars.material_override.set_shader_parameter("prob", randf_range(0.91, 1.0))
	$BGStars.material_override.set_shader_parameter("size", randf_range(50.0, 120.0))
	# Establish this system's star(s)
	main_star_count = system_types.pick_random()
	for i in main_star_count:
		# Set positioning
		var x: float
		var y: float
		var z: float
		z = randf_range(-2500, -300)
		x = randf_range(z * -1.1, z * 1.1)
		y = randf_range(z / 0.8, z / -2.3)
		# Make sure the star is within bounds. because I cannot be bothered to do the math for this
		while Vector3(x, y, z).distance_to(Vector3.ZERO) > 3500.0:
			z = randf_range(-2500, -300)
			x = randf_range(z * -1.1, z * 1.1)
			y = randf_range(z / 0.8, z / -2.3)
		# Set star properties
		var colour = star_colours.pick_random()
		$Background.get_node("MainStar" + str(i + 1)).mesh.material.albedo_color = colour
		$Background.get_node("MainStar" + str(i + 1)).mesh.material.emission = colour
		$Background.get_node("MainStar" + str(i + 1)).mesh.radius = randf_range(40, 250)
		$Background.get_node("MainStar" + str(i + 1)).mesh.height = $Background.get_node("MainStar" + str(i + 1)).mesh.radius * 2
		$Background.get_node("MainStar" + str(i + 1)).position = Vector3(x, y, z)
		if ($Background.get_node("MainStar" + str(i + 1)).mesh.radius / 2) / Vector3(x, y, z).distance_to(Vector3.ZERO) > 0.21:
			star_proximity = true
	# Create nebulae
	var nebula_pos: Vector3
	var nebula_colour: Color = Color(randf_range(0.1, 1.0), randf_range(0.1, 1.0), randf_range(0.1, 1.0))
	for i in randi_range(1, 22):
		nebula_pos = Vector3(randf_range(-2000, 2000), randf_range(-1000, 800), randf_range(-2000, -800))
		nebula_colour += Color(randf_range(-0.1, 0.1), randf_range(-0.1, 0.1), randf_range(-0.1, 0.1))
		# Big or small nebula
		if randi_range(0, 40) == 4: # Because I like the number 4
			# Big
			for j in randi_range(50, 300):
				var new_nebula = bg_nebula.instantiate()
				new_nebula.position = nebula_pos
				new_nebula.mesh.material.albedo_color = Color(nebula_colour, 0.05)
				new_nebula.mesh.material.emission = Color(nebula_colour)
				new_nebula.mesh.radius = randf_range(20, 50)
				new_nebula.mesh.height = new_nebula.mesh.radius * 2
				nebula_pos += Vector3(randf_range(-75, 75), randf_range(-100, 100), randf_range(-100, 100))
				$Background.add_child(new_nebula)
		else:
			# Small
			for j in randi_range(1, 20):
				var new_nebula = bg_nebula.instantiate()
				new_nebula.position = nebula_pos
				new_nebula.mesh.material.albedo_color = Color(nebula_colour, 0.04)
				new_nebula.mesh.material.emission = Color(nebula_colour)
				new_nebula.mesh.radius = randf_range(20, 50)
				new_nebula.mesh.height = new_nebula.mesh.radius * 2
				nebula_pos += Vector3(randf_range(-50, 50), randf_range(-50, 50), randf_range(-50, 50))
				$Background.add_child(new_nebula)
	# Set up conditions for the warp in dialogue
	system_properties.append(main_star_count)
	if Global.galaxy_data[Global.current_system]["enemy presence"]:
		system_properties.append("enemy presence")
		var enemy_fleet: Array = pirate_fleets[system_stage].pick_random()
		for ship in enemy_fleet:
			Global.create_enemy_ship(ship)
	if star_proximity:
		system_properties.append("star proximity")


func _process(delta: float) -> void:
	# UI stuff
	if Input.is_action_just_pressed("debug quit"):
		get_tree().quit()
	if Input.is_action_pressed("hide ui"):
		%UserInterface.hide()
	else:
		%UserInterface.show()
	
	if Global.in_combat:
		warp_charge += Global.charge_rate * delta
		if $FriendlyShips.get_child(0).hull <= 0:
			Global.in_combat = false
			# Lose the game
		if $HostileShips.get_child_count() < 1:
			Global.in_combat = false
			# Win the encounter


# Start warp animations
func commence_warp() -> void:
	for ship in $FriendlyShips.get_children():
		ship.begin_warp()
