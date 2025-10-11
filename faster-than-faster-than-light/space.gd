extends Node3D


@export var bg_nebula: PackedScene
@export var starship: PackedScene
var system_types: Array[int] = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 3]
var star_colours: Array[Color] = [Color(1, 1, 0), Color(1, 0.3, 0), Color(1, 0.1, 0), Color(0.9, 0.9, 0.9), Color(0.6, 0.6, 1), Color(0.3, 0.3, 1), Color(0.1, 0.1, 1)]
var main_star_count: String # Trust me, it just has to be this way
var system_properties: Array = []
var system_stage: String
var star_proximity: bool = false
var warp_charge: float = 0.0
var bg_object_rotation: float = 5.0
var enemy_ship_count: int
var run_away: bool = false
var enemy_aggression: int

const MUSIC_FADE_RATE: float = 0.8

var tutorial_enemy_fleet: Array = [[1, 0, [0]], [2, 0, [0]], [6, 0, [0]]]

var pirate_fleets: Dictionary = {
	"start": [
		[
			[1, 0, [0]],
			[1, 0, [0]],
		],
		[
			[1, 0, [0]],
			[1, 0, [5]],
		],
		[
			[1, 0, [5]],
			[2, 0, [0]],
		],
		[
			[1, 0, [0]],
			[3, 0, [0]],
		],
		[
			[1, 0, [0]],
			[4, 0, [0]],
		],
		[
			[1, 0, [0]],
			[5, 0, [0]],
		],
		[
			[1, 0, [0]],
			[6, 0, [0]],
		],
		[
			[1, 0, [0]],
			[2, 0, [0]],
			[3, 0, [0]],
		],
		[
			[1, 0, [0]],
			[2, 0, [0]],
			[4, 0, [0]],
		],
		[
			[1, 0, [5]],
			[2, 0, [0]],
			[6, 0, [0]],
		],
		[
			[1, 0, [0]],
			[3, 0, [0]],
			[5, 0, [0]],
		],
		[
			[1, 0, [0]],
			[3, 0, [0]],
			[4, 0, [0]],
		],
		[
			[1, 0, [0]],
			[3, 0, [0]],
			[6, 0, [0]],
		],
		[
			[1, 0, [0]],
			[4, 0, [0]],
			[4, 0, [0]],
		],
		[
			[1, 0, [0]],
			[4, 0, [0]],
			[5, 0, [0]],
		],
		[
			[1, 0, [0]],
			[4, 0, [0]],
			[6, 0, [0]],
		],
		[
			[1, 0, [0]],
			[5, 0, [0]],
			[5, 0, [0]],
		],
		[
			[1, 1, [0, 5]],
		],
		[
			[1, 0, [1]],
			[6, 0, [0]],
		],
	],
	"early": [
		[
			[1, 1, [0, 1]],
			[1, 1, [0, 1]],
		],
		[
			[1, 0, [1]],
			[1, 0, [1]],
			[2, 0, [0]],
		],
		[
			[1, 0, [1]],
			[2, 0, [0]],
			[2, 0, [0]],
		],
	],
	"middle": [
		
	],
	"late": [
		
	]
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
	
	$MusicExplore.play(Global.game_music_progress)
	$MusicCombat.play(Global.game_music_progress)
	
	if Global.galaxy_data[Global.current_system]["position"].x > 2400:
		system_stage = "late"
	elif Global.galaxy_data[Global.current_system]["position"].x > 1600:
		system_stage = "middle"
	elif Global.galaxy_data[Global.current_system]["position"].x > 800:
		system_stage = "early"
	else:
		system_stage = "start"
	
	var star_index: int = 1
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
		main_star_count = str(system_types.pick_random())
		Global.galaxy_data[Global.current_system]["main star count"] = main_star_count
		for star in get_tree().get_nodes_in_group(main_star_count):
			# Set star colour
			var colour: Color = star_colours.pick_random()
			star.mesh.material.albedo_color = colour
			star.mesh.material.emission = colour
			Global.galaxy_data[Global.current_system]["star" + str(star_index) + " colour"] = colour
			# Set star size
			var radius: float = randf_range(40.0, 250.0)
			star.mesh.radius = radius
			star.mesh.height = radius * 2.0
			Global.galaxy_data[Global.current_system]["star" + str(star_index) + " radius"] = radius
			# Set positioning
			var star_position: Vector3 = star_reposition()
			var not_colliding: int = 1
			while not_colliding == get_tree().get_node_count_in_group(main_star_count):
				for other_star in get_tree().get_nodes_in_group(main_star_count):
					if other_star != star and star_position.distance_to(other_star.position) < star.mesh.radius + other_star.mesh.radius:
						star_position = star_reposition()
					else:
						not_colliding += 1
			star.position = star_position
			Global.galaxy_data[Global.current_system]["star" + str(star_index) + " position"] = star_position
			# This doesn't need to be saved since it's pretty minor so I'm not gonna save it
			star.mesh.material.emission_texture.noise.seed = randi()
			# It took way too much rigorous testing to get this number
			if (radius / 2.0) / star_position.distance_to(Vector3.ZERO) > 0.21:
				star_proximity = true
				%UserInterface.get_node("SolarFlareFlash").color = colour
			star_index += 1
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
		for star in get_tree().get_nodes_in_group(Global.galaxy_data[Global.current_system]["main star count"]):
			var star_position: Vector3 = Global.galaxy_data[Global.current_system]["star" + str(star_index) + " position"]
			star.position = star_position
			var colour: Color = Global.galaxy_data[Global.current_system]["star" + str(star_index) + " colour"]
			star.mesh.material.albedo_color = colour
			star.mesh.material.emission = colour
			var radius: float = Global.galaxy_data[Global.current_system]["star" + str(star_index) + " radius"]
			star.mesh.radius = radius
			star.mesh.height = radius * 2.0
			# Not saved because it's not important enough (ouch)
			star.mesh.material.emission_texture.noise.seed = randi()
			if (radius / 2.0) / star_position.distance_to(Vector3.ZERO) > 0.21:
				star_proximity = true
			star_index += 1
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
	system_properties.append(int(main_star_count))
	# Is it a tutorial?
	if Global.tutorial:
		system_properties.append("tutorial")
	# Is the destination?
	if Global.current_system == Global.destination:
		system_properties.append("destination")
	# Are there enemies present?
	if Global.galaxy_data[Global.current_system]["enemy presence"]:
		system_properties.append("enemy presence")
		if Global.current_system not in Global.visited_systems:
			var enemy_fleet: Array
			if Global.tutorial:
				enemy_fleet = tutorial_enemy_fleet
			else:
				enemy_fleet = pirate_fleets[system_stage].pick_random()
			enemy_ship_count = len(enemy_fleet)
			enemy_aggression = randi_range(-1, enemy_ship_count)
			enemy_fleet.shuffle()
			for ship in enemy_fleet:
				Global.create_enemy_ship(ship[0], ship[1], ship[2])
		else:
			for enemy in Global.galaxy_data[Global.current_system]["enemies"]:
				$HostileShips.add_child(enemy)
	# Is there a shop?
	if Global.galaxy_data[Global.current_system]["shop presence"]:
		system_properties.append("shop presence")
	# Is there a star close by?
	if star_proximity and not Global.tutorial:
		system_properties.append("star proximity")
		$SolarFlare.start()


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
	
	Global.game_music_progress += delta
	
	if Global.in_combat:
		warp_charge += Global.charge_rate * delta
		$MusicExplore.volume_linear = move_toward($MusicExplore.volume_linear, 0.0, delta * MUSIC_FADE_RATE)
		$MusicCombat.volume_linear = move_toward($MusicCombat.volume_linear, 1.0, delta * MUSIC_FADE_RATE)
		if $HostileShips.get_child_count() < 1:
			# Win the encounter
			Global.in_combat = false
			%UserInterface.win_encounter()
		elif not run_away and $HostileShips.get_child_count() < enemy_aggression:
			run_away = true
			%UserInterface.dialogue_set_up(6, randi_range(0, len(%UserInterface.enemy_running_dialogue) - 1))
			$RunAway.start()
	else:
		$MusicExplore.volume_linear = move_toward($MusicExplore.volume_linear, 1.0, delta * MUSIC_FADE_RATE)
		$MusicCombat.volume_linear = move_toward($MusicCombat.volume_linear, 0.0, delta * MUSIC_FADE_RATE)
	
	if not $MusicExplore.playing and not $MusicCombat.playing:
		$MusicExplore.play()
		$MusicCombat.play()
		Global.game_music_progress = 0.0


# Start warp animations
func commence_warp() -> void:
	for ship in $FriendlyShips.get_children():
		ship.begin_warp()


func _on_solar_flare_timeout() -> void:
	if not "shop presence" in system_properties:
		for existing_starship in get_tree().get_nodes_in_group("starships"):
			existing_starship.hull -= randi_range(0, 2)
		%UserInterface.get_node("SolarFlareFlash").self_modulate.a = 0.4


func _on_run_away_timeout() -> void:
	for ship in $HostileShips.get_children():
		ship.begin_warp()


func star_reposition() -> Vector3:
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
	return Vector3(x, y, z)
