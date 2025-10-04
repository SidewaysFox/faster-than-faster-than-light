extends Node3D


@export var bg_nebula: PackedScene
@export var starship: PackedScene
var system_types: Array[int] = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 3]
var star_colours: Array[Color] = [Color(1, 1, 0), Color(1, 0.3, 0), Color(1, 0.1, 0), Color(0.9, 0.9, 0.9), Color(0.6, 0.6, 1), Color(0.3, 0.3, 1), Color(0.1, 0.1, 1)]
var main_star_count: int
var system_properties: Array = []
var system_stage: String
var star_proximity: bool = false
var warp_charge: float = 0.0
var bg_object_rotation: float = 5.0

var tutorial_enemy_fleet: Array = [1, 6]

var pirate_fleets: Dictionary = {
	"start": [
		[1, 1],
		[1, 2],
		[1, 3],
		[1, 4],
		[1, 5],
		[1, 6],
		#[1, 7],
		[1, 2, 4],
		[1, 1, 3],
		[1, 3, 3],
		[1, 3, 4],
		[1, 4, 4],
	],
	"early": [
		[1, 1, 1],
		[1, 1, 2],
		[1, 1, 3],
		[1, 1, 4],
		[1, 1, 5],
		[1, 1, 6],
		[1, 3, 3],
		[1, 1, 1, 4],
		[1, 1, 2, 4],
		[1, 1, 1, 1],
		[1, 1, 1, 6],
		[1, 1, 4, 4],
		[1, 1, 6, 6],
		[1, 2, 3, 4],
	],
	"middle": [
		[1, 1, 1, 1, 1],
		[1, 1, 1, 4, 4],
		[1, 1, 1, 1, 6],
		[1, 1, 2, 4],
		[1, 1, 1, 1, 1, 1],
		[1, 1, 1, 1, 1, 6],
	],
	"late": [
		[1, 1, 1, 1, 1, 1, 1, 1],
		[1, 1, 1, 1, 1, 1, 6, 6],
		[1, 1, 1, 2, 2, 2, 3],
		[1, 1, 1, 2, 2, 2, 3, 4],
		[1, 1, 2, 3, 3, 3, 3, 4],
	]
}

const PIRATE_WEAPONS: Dictionary = {
	"start": [0, 5]
}

signal setup_complete


func _ready() -> void:
	if Global.initialising:
		Global.establish()
		setup_complete.emit()
		Global.initialising = false
	else:
		# Spawn fleet
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
	
	# Check if the current system is new
	if Global.current_system not in Global.visited_systems or Global.unique_visits == 1:
		# Generate new system
		# Pass information to the BGStar GLSL script
		var bg_parameters: Array[float] = [randf_range(0.01, 100.0), randf_range(0.91, 1.0), randf_range(50.0, 120.0)]
		$BGStars.material_override.set_shader_parameter("seed", bg_parameters[0])
		$BGStars.material_override.set_shader_parameter("prob", bg_parameters[1])
		$BGStars.material_override.set_shader_parameter("size", bg_parameters[2])
		Global.galaxy_data[Global.current_system]["bg parameters"] = bg_parameters
		# Establish this system's star(s)
		main_star_count = system_types.pick_random()
		Global.galaxy_data[Global.current_system]["main star count"] = main_star_count
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
			$Background.get_node("MainStar" + str(i + 1)).position = Vector3(x, y, z)
			Global.galaxy_data[Global.current_system]["star" + str(i) + " position"] = Vector3(x, y, z)
			# Set star properties
			var colour: Color = star_colours.pick_random()
			$Background.get_node("MainStar" + str(i + 1)).mesh.material.albedo_color = colour
			$Background.get_node("MainStar" + str(i + 1)).mesh.material.emission = colour
			Global.galaxy_data[Global.current_system]["star" + str(i) + " colour"] = colour
			var radius: float = randf_range(40.0, 250.0)
			$Background.get_node("MainStar" + str(i + 1)).mesh.radius = radius
			$Background.get_node("MainStar" + str(i + 1)).mesh.height = radius * 2.0
			Global.galaxy_data[Global.current_system]["star" + str(i) + " radius"] = radius
			# This doesn't need to be saved since it's pretty minor so I'm not gonna save it
			$Background.get_node("MainStar" + str(i + 1)).mesh.material.emission_texture.noise.seed = randi()
			$Background.get_node("MainStar" + str(i + 1)).look_at(Vector3.ZERO)
			# It took way too much rigorous testing to get this number
			if (radius / 2.0) / Vector3(x, y, z).distance_to(Vector3.ZERO) > 0.21:
				star_proximity = true
		# Create nebulae
		var nebula_pos: Vector3
		var nebula_colour: Color = Color(randf_range(0.1, 1.0), randf_range(0.1, 1.0), randf_range(0.1, 1.0), randf_range(0.05, 0.2))
		Global.galaxy_data[Global.current_system]["nebulae"] = []
		for i in randi_range(1, 22):
			# Not as important that it remains in bounds
			nebula_pos = Vector3(randf_range(-2000, 2000), randf_range(-1000, 800), randf_range(-2000, -800))
			nebula_colour += Color(randf_range(-0.1, 0.1), randf_range(-0.1, 0.1), randf_range(-0.1, 0.1), randf_range(-0.05, 0.05))
			nebula_colour.a = clamp(nebula_colour.a, 0.04, 0.2)
			# Big or small nebula
			Global.galaxy_data[Global.current_system]["nebulae"].append([])
			if randi_range(0, 40) == 4: # Because I like the number 4
				# Big
				for j in randi_range(50, 300):
					var new_nebula: Node = bg_nebula.instantiate()
					new_nebula.position = nebula_pos
					new_nebula.mesh.material.albedo_color = nebula_colour
					new_nebula.mesh.material.emission = nebula_colour
					var neb_radius: float = randf_range(20.0, 50.0)
					new_nebula.mesh.radius = neb_radius
					new_nebula.mesh.height = neb_radius * 2.0
					Global.galaxy_data[Global.current_system]["nebulae"][i].append([nebula_pos, nebula_colour, neb_radius])
					$Background.add_child(new_nebula)
					nebula_pos += Vector3(randf_range(-75, 75), randf_range(-100, 100), randf_range(-100, 100))
			else:
				# Small
				for j in randi_range(1, 20):
					var new_nebula: Node = bg_nebula.instantiate()
					new_nebula.position = nebula_pos
					new_nebula.mesh.material.albedo_color = nebula_colour
					new_nebula.mesh.material.emission = nebula_colour
					var neb_radius: float = randf_range(20.0, 50.0)
					new_nebula.mesh.radius = neb_radius
					new_nebula.mesh.height = neb_radius * 2.0
					Global.galaxy_data[Global.current_system]["nebulae"][i].append([nebula_pos, nebula_colour, neb_radius])
					$Background.add_child(new_nebula)
					nebula_pos += Vector3(randf_range(-50, 50), randf_range(-50, 50), randf_range(-50, 50))
	else:
		# Load existing system data
		$BGStars.material_override.set_shader_parameter("seed", Global.galaxy_data[Global.current_system]["bg parameters"][0])
		$BGStars.material_override.set_shader_parameter("prob", Global.galaxy_data[Global.current_system]["bg parameters"][1])
		$BGStars.material_override.set_shader_parameter("size", Global.galaxy_data[Global.current_system]["bg parameters"][2])
		for i in Global.galaxy_data[Global.current_system]["main star count"]:
			var star_position: Vector3 = Global.galaxy_data[Global.current_system]["star" + str(i) + " position"]
			$Background.get_node("MainStar" + str(i + 1)).position = star_position
			var colour: Color = Global.galaxy_data[Global.current_system]["star" + str(i) + " colour"]
			$Background.get_node("MainStar" + str(i + 1)).mesh.material.albedo_color = colour
			$Background.get_node("MainStar" + str(i + 1)).mesh.material.emission = colour
			var radius: float = Global.galaxy_data[Global.current_system]["star" + str(i) + " radius"]
			$Background.get_node("MainStar" + str(i + 1)).mesh.radius = radius
			$Background.get_node("MainStar" + str(i + 1)).mesh.height = radius * 2.0
			# Not saved because it's not important enough (ouch)
			$Background.get_node("MainStar" + str(i + 1)).mesh.material.emission_texture.noise.seed = randi()
			$Background.get_node("MainStar" + str(i + 1)).look_at(Vector3.ZERO)
			if (radius / 2.0) / star_position.distance_to(Vector3.ZERO) > 0.21:
				star_proximity = true
		for nebula in Global.galaxy_data[Global.current_system]["nebulae"]:
			for sphere in nebula:
				var new_nebula: Node = bg_nebula.instantiate()
				new_nebula.position = sphere[0]
				new_nebula.mesh.material.albedo_color = sphere[1]
				new_nebula.mesh.material.emission = sphere[1]
				new_nebula.mesh.radius = sphere[2]
				new_nebula.mesh.height = sphere[2] * 2.0
				$Background.add_child(new_nebula)
	
	# Set up conditions for the warp in dialogue
	system_properties.append(main_star_count)
	# Is it a tutorial?
	if Global.tutorial:
		system_properties.append("tutorial")
	# Is the destination?
	if Global.current_system == Global.destination:
		system_properties.append("destination")
	# Are there enemies present?
	if Global.galaxy_data[Global.current_system]["enemy presence"]:
		system_properties.append("enemy presence")
		var enemy_fleet: Array
		if Global.tutorial:
			enemy_fleet = tutorial_enemy_fleet
		else:
			enemy_fleet = pirate_fleets[system_stage].pick_random()
		enemy_fleet.shuffle()
		for ship in enemy_fleet:
			Global.create_enemy_ship(ship)
	# Is there a shop?
	if Global.galaxy_data[Global.current_system]["shop presence"]:
		system_properties.append("shop presence")
	# Is there a star close by?
	if star_proximity and not Global.tutorial:
		system_properties.append("star proximity")


func _process(delta: float) -> void:
	# UI stuff
	if Input.is_action_just_pressed("debug quit"):
		get_tree().quit()
	if Input.is_action_pressed("hide ui"):
		%UserInterface.hide()
	else:
		%UserInterface.show()
	
	for child in $Background.get_children():
		child.rotation_degrees.y += bg_object_rotation * delta
	
	if Global.playing:
		if Input.is_action_just_pressed("debug die"):
			$FriendlyShips.get_child(0).hull = 0
		
		if $FriendlyShips.get_child(0).hull <= 0:
			# Lose the game
			Global.in_combat = false
			%UserInterface.lose()
	
	if Global.in_combat:
		warp_charge += Global.charge_rate * delta
		if $HostileShips.get_child_count() < 1:
			# Win the encounter
			Global.in_combat = false
			%UserInterface.win_encounter()


# Start warp animations
func commence_warp() -> void:
	for ship in $FriendlyShips.get_children():
		ship.begin_warp()
