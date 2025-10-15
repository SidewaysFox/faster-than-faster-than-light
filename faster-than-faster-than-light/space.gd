extends Node3D


@export var bg_nebula: PackedScene
@export var starship: PackedScene
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
var main_star_count: String # Needs to be a string for use in other applications
var system_properties: Array = []
var system_stage: int
var star_proximity: bool = false
var warp_charge: float = 0.0
var bg_object_rotation: float = 5.0
var enemy_ship_count: int
var run_away: bool = false
var enemy_aggression: int
var warp_in_dialogue_needed: bool = true

const LATE_GAME: float = 2400.0
const MID_GAME: float = 1600.0
const EARLY_GAME: float = 800.0
const MUSIC_FADE_RATE: float = 0.8
const SOLAR_FLARE_SFX_DELAY: float = 2.05
const MAX_SOLAR_FLARE_DAMAGE: int = 2
const SOLAR_FLARE_ALPHA: float = 0.4

const BG_STARS_SEED: Vector2 = Vector2(0.01, 100.0)
const BG_STARS_PROB: Vector2 = Vector2(0.91, 1.0)
const BG_STARS_SIZE: Vector2 = Vector2(50.0, 120.0)
const RADIUS_RANGE: Vector2 = Vector2(40.0, 250.0)
const HEIGHT_FACTOR: float = 2.0
const STAR_POS_Z: Vector2 = Vector2(-2500, -300)
const STAR_X_FACTOR: float = 1.1
const STAR_Y_FACTOR: Vector2 = Vector2(0.8, -2.3)
const STAR_PROXIMITY_THRESHOLD: float = 0.21
const PROXIMITY_RADIUS_WEIGHT: float = 0.5
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
const SAVE_DELAY: float = 0.2

enum GameStage {
	START,
	EARLY,
	MID,
	LATE
}

var tutorial_enemy_fleet: Array[Array] = [[1, 0, [0]], [2, 0, [0]], [6, 0, [0]]]

var pirate_fleets: Dictionary = {
	GameStage.START: [
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
	GameStage.EARLY: [
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
	GameStage.MID: [
		
	],
	GameStage.LATE: [
		
	]
}

signal setup_complete


func _ready() -> void:
	# If this is the first system, establish/initialise the game
	if Global.initialising:
		Global.establish()
		setup_complete.emit()
		Global.initialising = false
		# If this is a continued/loaded game, duplicate ships to spawn the fleet as usual
		if Global.continuing:
			for ship in Global.fleet:
				$FriendlyShips.add_child(ship.duplicate())
	else:
		# Spawn fleet
		for ship in Global.fleet:
			$FriendlyShips.add_child(ship.duplicate())
	
	# Begin playing the music from where it last left off
	$MusicExplore.play(Global.game_music_progress)
	$MusicCombat.play(Global.game_music_progress)
	
	# Check what section of the game this is
	if Global.galaxy_data[Global.current_system]["position"].x > LATE_GAME:
		system_stage = GameStage.LATE
	elif Global.galaxy_data[Global.current_system]["position"].x > MID_GAME:
		system_stage = GameStage.MID
	elif Global.galaxy_data[Global.current_system]["position"].x > EARLY_GAME:
		system_stage = GameStage.EARLY
	else:
		system_stage = GameStage.START
	
	# Generate the system
	var star_index: int = 1
	# Check if the current system is new
	if Global.current_system not in Global.visited_systems or Global.unique_visits == 1:
		# Current system is new - information will have to be generated and then saved as data
		# Pass information to the BGStar GLSL script
		var bg_seed: float = randf_range(BG_STARS_SEED.x, BG_STARS_SEED.y)
		var bg_prob: float = randf_range(BG_STARS_PROB.x, BG_STARS_PROB.y)
		var bg_size: float = randf_range(BG_STARS_SIZE.x, BG_STARS_SIZE.y)
		$BGStars.material_override.set_shader_parameter("seed", bg_seed)
		$BGStars.material_override.set_shader_parameter("prob", bg_prob)
		$BGStars.material_override.set_shader_parameter("size", bg_size)
		Global.galaxy_data[Global.current_system]["bg parameters"] = [bg_seed, bg_prob, bg_size]
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
			var radius: float = randf_range(RADIUS_RANGE.x, RADIUS_RANGE.y)
			star.mesh.radius = radius
			star.mesh.height = radius * HEIGHT_FACTOR
			Global.galaxy_data[Global.current_system]["star" + str(star_index) + " radius"] = radius
			# Set positioning
			var star_position: Vector3 = star_reposition()
			var not_colliding: int = 1
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
			Global.galaxy_data[Global.current_system]["star" + str(star_index) + " position"] \
					= star_position
			# This doesn't need to be saved since it's pretty minor
			star.mesh.material.emission_texture.noise.seed = randi()
			if (
					(radius * PROXIMITY_RADIUS_WEIGHT) / star_position.distance_to(Vector3.ZERO)
					> STAR_PROXIMITY_THRESHOLD
			):
				star_proximity = true
				%UserInterface.get_node("SolarFlareFlash").color = colour
			star_index += 1
		# Create nebulae
		var nebula_pos: Vector3
		var nebula_colour: Color = Color(
				randf_range(NEB_COL.x, NEB_COL.y),
				randf_range(NEB_COL.x, NEB_COL.y),
				randf_range(NEB_COL.x, NEB_COL.y),
				randf_range(NEB_ALPHA.x, NEB_ALPHA.y)
		)
		Global.galaxy_data[Global.current_system]["nebulae"] = []
		for nebula in randi_range(NEB_COUNT.x, NEB_COUNT.y):
			# Not as important that it remains in bounds
			nebula_pos = Vector3(
					randf_range(NEB_POS_X.x, NEB_POS_X.y),
					randf_range(NEB_POS_Y.x, NEB_POS_Y.y),
					randf_range(NEB_POS_Z.x, NEB_POS_Z.y)
			)
			nebula_colour += Color(
					randf_range(-NEB_COL_SHIFT, NEB_COL_SHIFT),
					randf_range(-NEB_COL_SHIFT, NEB_COL_SHIFT),
					randf_range(-NEB_COL_SHIFT, NEB_COL_SHIFT),
					randf_range(-NEB_ALPHA_SHIFT, NEB_ALPHA_SHIFT)
			)
			nebula_colour.a = clamp(nebula_colour.a, NEB_ALPHA.x, NEB_ALPHA.y)
			# Big or small nebula
			Global.galaxy_data[Global.current_system]["nebulae"].append([])
			if randi_range(0, LARGE_NEB_CHANCE) == 0:
				# Big
				for cloud in randi_range(LARGE_NEB_SIZE.x, LARGE_NEB_SIZE.y):
					var new_nebula: MeshInstance3D = bg_nebula.instantiate()
					new_nebula.position = nebula_pos
					new_nebula.mesh.material.albedo_color = nebula_colour
					new_nebula.mesh.material.emission = nebula_colour
					var neb_radius: float = randf_range(NEB_RADIUS.x, NEB_RADIUS.y)
					new_nebula.mesh.radius = neb_radius
					new_nebula.mesh.height = neb_radius * HEIGHT_FACTOR
					Global.galaxy_data[Global.current_system]["nebulae"][nebula].append(
							[nebula_pos, nebula_colour, neb_radius]
					)
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
					var neb_radius: float = randf_range(20.0, 50.0)
					new_nebula.mesh.radius = neb_radius
					new_nebula.mesh.height = neb_radius * 2.0
					Global.galaxy_data[Global.current_system]["nebulae"][nebula].append(
							[nebula_pos, nebula_colour, neb_radius]
					)
					$Background.add_child(new_nebula)
					nebula_pos += Vector3(
							randf_range(-NEB_POS_SHIFT, NEB_POS_SHIFT),
							randf_range(-NEB_POS_SHIFT, NEB_POS_SHIFT),
							randf_range(-NEB_POS_SHIFT, NEB_POS_SHIFT)
					)
	else:
		# Current system is not new
		warp_in_dialogue_needed = false
		# Load existing system data
		$BGStars.material_override.set_shader_parameter(
				"seed",
				Global.galaxy_data[Global.current_system]["bg parameters"][0]
		)
		$BGStars.material_override.set_shader_parameter(
				"prob",
				Global.galaxy_data[Global.current_system]["bg parameters"][1]
		)
		$BGStars.material_override.set_shader_parameter(
				"size",
				Global.galaxy_data[Global.current_system]["bg parameters"][2]
		)
		# Stars
		for star in get_tree().get_nodes_in_group(
				Global.galaxy_data[Global.current_system]["main star count"]
		):
			var star_position: Vector3 = Global.galaxy_data[Global.current_system][
					"star" + str(star_index) + " position"
			]
			star.position = star_position
			var colour: Color = Global.galaxy_data[Global.current_system][
					"star" + str(star_index) + " colour"
			]
			star.mesh.material.albedo_color = colour
			star.mesh.material.emission = colour
			var radius: float = Global.galaxy_data[Global.current_system][
					"star" + str(star_index) + " radius"
			]
			star.mesh.radius = radius
			star.mesh.height = radius * HEIGHT_FACTOR
			# Not saved because it's not important enough (ouch)
			star.mesh.material.emission_texture.noise.seed = randi()
			if ((radius * PROXIMITY_RADIUS_WEIGHT) / star_position.distance_to(Vector3.ZERO)
					> STAR_PROXIMITY_THRESHOLD
			):
				star_proximity = true
			star_index += 1
		# Nebulae
		for nebula in Global.galaxy_data[Global.current_system]["nebulae"]:
			for sphere in nebula:
				var new_nebula: MeshInstance3D = bg_nebula.instantiate()
				new_nebula.position = sphere[0]
				new_nebula.mesh.material.albedo_color = sphere[1]
				new_nebula.mesh.material.emission = sphere[1]
				new_nebula.mesh.radius = sphere[2]
				new_nebula.mesh.height = sphere[2] * HEIGHT_FACTOR
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
		var enemy_fleet: Array
		# Is this the tutorial fight?
		if Global.tutorial:
			enemy_fleet = tutorial_enemy_fleet
		elif Global.current_system not in Global.visited_systems:
			enemy_fleet = pirate_fleets[system_stage].pick_random()
			Global.galaxy_data[Global.current_system]["enemies"] = enemy_fleet
		else:
			enemy_fleet = Global.galaxy_data[Global.current_system]["enemies"]
		# Spawn the enemy fleet
		enemy_ship_count = len(enemy_fleet)
		Global.galaxy_data[Global.current_system]["enemy count"] = enemy_ship_count
		enemy_aggression = randi_range(-1, enemy_ship_count)
		enemy_fleet.shuffle()
		for ship in enemy_fleet:
			Global.create_enemy_ship(ship[0], ship[1], ship[2])
	# Is there a shop?
	if Global.galaxy_data[Global.current_system]["shop presence"]:
		system_properties.append("shop presence")
	# Is there a star close by?
	if star_proximity and not Global.tutorial:
		system_properties.append("star proximity")
		$SolarFlare.start()
	
	# Save the game after a short delay
	await get_tree().create_timer(SAVE_DELAY).timeout
	Global.new_system(Global.current_system)
	Global.save_game()


func _process(delta: float) -> void:
	# UI stuff
	if Input.is_action_just_pressed("debug quit"):
		get_tree().quit()
	if Input.is_action_pressed("hide ui"):
		%UserInterface.hide()
	else:
		%UserInterface.show()
	
	# Spin the background objects
	for child in $Background.get_children():
		child.rotation_degrees.y += bg_object_rotation * delta
	
	# Is it possible for the player to lose?
	if Global.playing:
		if Input.is_action_just_pressed("debug die"):
			$FriendlyShips.get_child(0).hull = 0
		
		if $FriendlyShips.get_child(0).hull <= 0:
			# Lose the game
			Global.in_combat = false
			%UserInterface.lose()
	
	# Currently in combat?
	if Global.in_combat:
		warp_charge += Global.charge_rate * delta
		# Shift music to combat
		$MusicExplore.volume_linear = move_toward(
				$MusicExplore.volume_linear,
				0.0,
				delta * MUSIC_FADE_RATE
		)
		$MusicCombat.volume_linear = move_toward(
				$MusicCombat.volume_linear,
				1.0,
				delta * MUSIC_FADE_RATE
		)
		if $HostileShips.get_child_count() < 1:
			# Win the encounter
			Global.in_combat = false
			%UserInterface.win_encounter()
		# Is the enemy going to attempt to escape now?
		elif not run_away and $HostileShips.get_child_count() < enemy_aggression:
			run_away = true
			%UserInterface.dialogue_set_up(
					%UserInterface.DialogueTypes.ENEMY_RUNNING,
					randi_range(0, len(%UserInterface.enemy_running_dialogue) - 1)
			)
			$RunAway.start()
	else:
		# Shift music to exploration
		$MusicExplore.volume_linear = move_toward(
				$MusicExplore.volume_linear,
				1.0,
				delta * MUSIC_FADE_RATE
		)
		$MusicCombat.volume_linear = move_toward(
				$MusicCombat.volume_linear,
				0.0,
				delta * MUSIC_FADE_RATE
		)
	
	# Restart the music if it has finished
	if not $MusicExplore.playing and not $MusicCombat.playing:
		$MusicExplore.play()
		$MusicCombat.play()
		Global.game_music_progress = 0.0


# Start warp animations
func commence_warp() -> void:
	for ship in $FriendlyShips.get_children():
		ship.begin_warp()


# Initiate a solar flare
func _on_solar_flare_timeout() -> void:
	var shop_in_system: bool = "shop presence" in system_properties
	# No effect if there is a shop in the system
	if not shop_in_system:
		$SolarFlareSFX.play()
		await get_tree().create_timer(SOLAR_FLARE_SFX_DELAY).timeout
		# Potentially deal damage to every existing ship
		for existing_starship in get_tree().get_nodes_in_group("starships"):
			existing_starship.hull -= randi_range(0, MAX_SOLAR_FLARE_DAMAGE)
		%UserInterface.get_node("SolarFlareFlash").self_modulate.a = SOLAR_FLARE_ALPHA


# Enemies successfully escape
func _on_run_away_timeout() -> void:
	for ship in $HostileShips.get_children():
		ship.begin_warp()


# Reposition star
func star_reposition() -> Vector3:
	var x: float
	var y: float
	var z: float
	z = randf_range(STAR_POS_Z.x, STAR_POS_Z.y)
	x = randf_range(z * -STAR_X_FACTOR, z * STAR_X_FACTOR)
	y = randf_range(z / STAR_Y_FACTOR.x, z / STAR_Y_FACTOR.y)
	# Make sure the star is within rendering bounds
	while Vector3(x, y, z).distance_to(Vector3.ZERO) > STAR_RENDER_DISTANCE:
		z = randf_range(STAR_POS_Z.x, STAR_POS_Z.y)
		x = randf_range(z * -STAR_X_FACTOR, z * STAR_X_FACTOR)
		y = randf_range(z / STAR_Y_FACTOR.x, z / STAR_Y_FACTOR.y)
	return Vector3(x, y, z)
