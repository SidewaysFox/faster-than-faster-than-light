extends Control


@onready var main: Node = get_node("/root/Space")
@export var galaxy_map_token: PackedScene
var fade_mode: int = -1
var cursor_speed: float = 250
var galaxy_map_showing: bool = false
var dialogue_showing: bool = true
var max_option: int = 3
var ready_to_select: bool = false
var current_dialogue_selection: int = 1
var option_results: Array
var action_menu_showing: bool = false
var hovered_ship: int = 0
var hovered_target: int = 0
var selected_ship: int = 0
var targeting_mode: int = 0
var time_paused: bool = false

var ship_codes: Array[String] = ["CMND", "FGHT", "SHLD", "INFL", "REPR", "SCAN", "RLAY", "DRON"]
var targeting_options: Array[String] = ["CANNOT TARGET", "TARGET", "CANNOT TARGET", "BOARD", "REPAIR", "MONITOR", "CANNOT TARGET", "DEPLOY"]


var warp_in_dialogue: Array = [ # Conditions, main text, [option, result]
	[[1],
	"As your fleet exits its jump, you take in the picturesque scenery around you.",
	[["Enjoy the view as your warp drives charge up once more.", ["close", false]]]
	],
	[[1],
	"You wait with bated breath, half expecting a rebel ambush as you exit warp, but none comes. You live another day.",
	[["Let's not wait around. Charge up the warp drives.", ["close", false]]]
	],
	[[1],
	"Although this system is devoid of anything of particular interest to your fleet, you can't help but remain apprehensive about your task and the rebel fleet chasing you. In these distant reaches of space, it feels like everything wants you dead.",
	[["Play some cards with your crew to ease your nerves while you wait for the warp drives to charge.", ["close", false]], ["Remain alone for the time being.", ["close", false]]]
	],
	[[1],
	"Despite your relatively unique journey so far, you find yourself ultimately feeling bored with nothing to do.",
	[["Hope for something interesting to happen.", ["close", false]], ["Remain careful for what you wish for.", ["close", false]]]
	],
	[[1],
	"As you warp into the system, your onboard threat assessment radar begins loudly blaring at you. After a couple minutes of your crew in complete panick attempting to identify a threat, you are told it was merely a false alarm.",
	[["Calm down and get the radar fixed.", ["close", false]], ["Punish the crew members operating the radar.", ["close", false]]]
	],
	[[1],
	"As you warp into the system, your fleet finds itself surrounded by a number of large wreckages. It looks like pirates must have found good prey in a convoy of freighters.",
	[["Scrap what's left of the freighter hulls.", ["resources", randi_range(5, 15), 0, true, 0, 1]]]
	],
	[[1],
	"As you warp into the system, your fleet finds itself surrounded by a number of large wreckages. It looks like pirates must have found good prey in a convoy of freighters.",
	[["Scrap what's left of the freighter hulls.", ["dialogue_set_up", 1, 1]]]
	],
	[[1],
	"As you warp into the system, your fleet finds itself surrounded by a number of large wreckages. It looks like pirates must have found good prey in a convoy of freighters.",
	[["Scrap what's left of the freighter hulls.", ["resources", randi_range(20, 40), 0, true, 2, 1]]]
	],
	[[1],
	"As you warp into the system, your fleet finds itself surrounded by a number of large wreckages. It looks like pirates must have found good prey in a convoy of freighters.",
	[["Scrap what's left of the freighter hulls.", ["resources", randi_range(3, 7), 1, true, 4, 1]]]
	],
	[[1, "enemy presence"],
	"As your fleet exits warp, you're greeted by a radio transmission from an unknown starship fleet.\n\"Ahh... I see we've been blessed by the presence of a resource-rich fleet. We'll be taking that, thank you very much.\"\nAs communications are cut, the pirate fleet starts charging its weapons!",
	[["Get ready for combat.", ["close", true]]]
	],
	[[2],
	"As your fleet exits its jump, you see two stars locked in each others' orbits. You spend a moment taking a deep breath, before returning to your duties on deck.",
	[["Enjoy the view as your warp drives charge up once more.", ["close", false]]]
	],
	[[2],
	"Another peaceful system.",
	[["Enjoy the view as your warp drives charge up once more.", ["close", false]]]
	],
	[[2, "enemy presence"],
	"As your fleet exits warp, you're greeted by a radio transmission from an unknown starship fleet.\n\"Ahh... I see we've been blessed by the presence of a resource-rich fleet. We'll be taking that, thank you very much.\"\nAs communications are cut, the pirate fleet starts charging its weapons!",
	[["Get ready for combat.", ["close", true]]]
	],
	[[3],
	"As your fleet exits its jump, you are surprised to find you and your fleet amongst a trinary star system, a rare sight for anyone not part of the navy.",
	[["Enjoy the view as your warp drives charge up once more.", ["close", false]]]
	],
	[[3, "enemy presence"],
	"As your fleet exits warp, you're greeted by a radio transmission from an unknown starship fleet.\n\"Ahh... I see we've been blessed by the presence of a resource-rich fleet - in a trinary system too! We'll be taking that, thank you very much.\"\nAs communications are cut, the pirate fleet starts charging its weapons!",
	[["Get ready for combat.", ["close", true]]]
	],
	[[1, "star proximity"],
	"As you exit warp, you realise you've ended up dangerously close to this system's star. Your ships could be in danger if you linger for too long.",
	[["Hope the star doesn't flare up while you wait for your warp drives to charge.", ["close", false]]]
	],
	[[1, "enemy presence", "star proximity"],
	"Your fleet exits warp, and you realise that you're uncomfortably close to a star. Suddenly, your systems warn you of a nearby threat. A pirate fleet either unaware or uncaring of the danger slides into view.",
	[["Hope that the star doesn't pose too much of an issue and get ready for combat.", ["close", true]]]
	],
	[[2, "star proximity"],
	"The binary system of stars you've just warped into makes it hard to miss the fact that you've come in far too close for comfort to one of them.",
	[["Hope the star doesn't flare up while you wait for your warp drives to charge.", ["close", false]]]
	],
	[[2, "enemy presence", "star proximity"],
	"Your fleet exits warp, and you realise that you're uncomfortably close to a star. Suddenly, your systems warn you of a nearby threat. A pirate fleet either unaware or uncaring of the danger slides into view.",
	[["Hope that the star doesn't pose too much of an issue and get ready for combat.", ["close", true]]]
	],
	[[3, "star proximity"],
	"You find yourself and your fleet in a trinary system, but your close proximity to one of the stars unfortunately means you cannot affort to take in the view.",
	[["Hope the star doesn't flare up while you wait for your warp drives to charge.", ["close", false]]]
	],
	[[3, "enemy presence", "star proximity"],
	"Your fleet exits warp, and you realise that you're uncomfortably close to a star. Suddenly, your systems warn you of a nearby threat. A pirate fleet either unaware or uncaring of the danger slides into view.",
	[["Hope that the star doesn't pose too much of an issue and get ready for combat.", ["close", true]]]
	],
]

var response_dialogue: Array = [ # Main text, [option, result]
	["As you search the wreckages, you manage to pick out some scraps.",
	[["Continue the journey.", ["close", false]]]
	],
	["You search the wreckages but there is nothing of value to find.",
	[["Continue the journey.", ["close", false]]]
	],
	["Looking through the charred remains of the freighters, you come across a hidden vault that the pirates must have missed. Opening the vault, you find a variety of exotic materials inside!",
	[["Celebrate and continue the journey.", ["close", false]]]
	],
	["You have lost.",
	[["Try once more.", ["restart"]], ["Give up.", ["quit"]]]
	],
	["Unfortunately no usable material was found, but some unused fuel canisters were successfully recovered.",
	[["Add them to your fleet's fuel reserves and continue the journey.", ["close", false]]]
	],
]

var encounter_win_dialogue: Array = [
	["As soon as the final ship in the enemy fleet is torn apart, you strip down each worn ship carcass for materials.",
	[["Continue the journey.", ["close", false]]]
	],
	["With the enemy fleet defeated, you order your crews to quickly search the wreckages for anything useful.",
	[["Collect scrap and continue the journey.", ["close", false]]]
	],
	["You barely manage to hear muffled screams through the static of the final enemy ship's transmitters. As the sound fades away, you gather resources from the fresh debris field.",
	[["Reap your reward and move on.", ["close", false]]]
	],
]


func _ready() -> void:
	$Dialogue.hide()
	$ScreenFade.show()
	%Gameplay/ControlMode.button_pressed = Global.joystick_control
	%Gameplay/JoystickMode.button_pressed = Global.dual_joysticks
	if Global.initilising:
		await main.setup_complete
	# Generate visual galaxy map
	for i in Global.galaxy_data:
		var new_token: Node = galaxy_map_token.instantiate()
		new_token.id = i["id"]
		new_token.position = i["position"]
		$GalaxyMap/Tokens.add_child(new_token)


func _process(delta: float) -> void:
	# debug stuff
	if Input.is_action_pressed("debug"):
		$FPS.show()
	else:
		$FPS.hide()
	$FPS.text = "FPS: " + str(1 / delta)
	
	# Update fuel and resource UI elements
	%ResourcesLabel.text = "TECH: " + str(Global.resources)
	%ResourcesLabel.add_theme_color_override("font_color", lerp(%ResourcesLabel.get_theme_color("font_color"), Color(1, 1, 1), 0.05))
	%FuelLabel.text = "FUEL: " + str(Global.fuel)
	%FuelLabel.add_theme_color_override("font_color", lerp(%FuelLabel.get_theme_color("font_color"), Color(1, 1, 1), 0.05))
	
	%ChargeProgress.value = main.warp_charge
	
	# Screen fade stuff
	$ScreenFade.color.a += fade_mode * delta
	$ScreenFade.color.a = clamp($ScreenFade.color.a, 0, 1)
	
	if Input.is_action_just_pressed("pause"):
		$PauseMenu.show()
		$PauseMenu/UnpauseTimer.start()
		get_tree().paused = true
	
	
	# Check if the dialogue is showing:
	if dialogue_showing:
		# Move selection up/down
		if Global.joystick_control:
			if Input.is_action_just_pressed("up1") or Input.is_action_just_pressed("up2"):
				current_dialogue_selection -= 1
			if Input.is_action_just_pressed("down1") or Input.is_action_just_pressed("down2"):
				current_dialogue_selection += 1
			current_dialogue_selection = clampi(current_dialogue_selection, 1, max_option)
			# Select
			if (Input.is_action_just_pressed("1") or Input.is_action_just_pressed("A")) and ready_to_select:
				select_dialogue(current_dialogue_selection)
			# Appropriately colour the selected option
			for i in max_option:
				if i + 1 == current_dialogue_selection:
					%Options.get_node("Option" + str(i + 1)).add_theme_color_override("font_color", Color(0, 0.75, 1.0))
				else:
					%Options.get_node("Option" + str(i + 1)).add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
		%ChargeProgress/Label.text = "WAITING"
	# Show or hide the galaxy map
	elif (((Input.is_action_just_pressed("4") or Input.is_action_just_pressed("D")) and Global.joystick_control) or (Input.is_action_just_pressed("galaxy map") and not Global.joystick_control)) and not action_menu_showing and main.warp_charge >= 100:
		_galaxy_map()
	elif Input.is_action_just_pressed("time pause") and not galaxy_map_showing:
		time_paused = not time_paused
	else:
		if main.warp_charge < 100:
			%ChargeProgress/Label.text = "WARP CHARGING"
		else:
			%ChargeProgress/Label.text = "WARP CHARGED"
		if (((Input.is_action_just_pressed("2") or Input.is_action_just_pressed("B")) and Global.joystick_control) or (Input.is_action_just_pressed("action menu") and not Global.joystick_control)) and not galaxy_map_showing:
			_action_menu()
	if time_paused:
		Engine.time_scale = lerp(Engine.time_scale, 0.0, 0.15)
		$TimeIndicator.show()
	else:
		Engine.time_scale = lerp(Engine.time_scale, 1.0, 0.15)
		$TimeIndicator.hide()
	# Galaxy map stuff
	if galaxy_map_showing:
		time_paused = false
		Engine.time_scale = 1.0
		$GalaxyMap.show()
		$GalaxyMapTitle.show()
		# Left/right scrolling
		if Input.is_action_pressed("right2"):
			$GalaxyMap/Tokens.position.x -= 400 * delta * Global.joystick_sens
		if Input.is_action_pressed("left2"):
			$GalaxyMap/Tokens.position.x += 400 * delta * Global.joystick_sens
		%Cursor.position += Vector2(Input.get_axis("left1", "right1"), Input.get_axis("up1", "down1")).normalized() * cursor_speed * Global.joystick_sens * delta
		# Cursor snapping
		if Input.get_axis("left1", "right1") == 0 and Input.get_axis("up1", "down1") == 0 and len(%Cursor.get_overlapping_areas()) > 0:
			var in_warp_range: bool = false
			var closest_token: Array = [0, 400]
			var n: int = 0
			for token in %Cursor.get_overlapping_areas():
				var x = [n, %Cursor.position.distance_squared_to(token.position), token.id]
				if x[1] < closest_token[1]:
					closest_token = x
					if token.position.distance_to(Global.system_position) <= Global.jump_distance:
						in_warp_range = true
				n += 1
			%Cursor.position = lerp(%Cursor.position, %Cursor.get_overlapping_areas()[closest_token[0]].position, 0.2)
			# Warping input
			if (((Input.is_action_just_pressed("1") or Input.is_action_just_pressed("A")) and Global.joystick_control) or (Input.is_action_just_pressed("warp") and not Global.joystick_control)) and in_warp_range and closest_token[2] != Global.current_system and Global.fuel >= len(Global.fleet):
				Engine.time_scale = 0
				time_paused = false
				galaxy_map_showing = false
				Global.in_combat = false
				Global.fuel -= len(Global.fleet)
				_quantity_change(1, false)
				Global.new_system(closest_token[2])
				# Warp sequence
				await get_tree().create_timer(1).timeout
				main.commence_warp()
				await get_tree().create_timer(2).timeout
				fade_mode = 1
				await get_tree().create_timer(3).timeout
				main.get_tree().reload_current_scene()
		# Clamping
		$GalaxyMap/Tokens.position.x = clampf($GalaxyMap/Tokens.position.x, -2040.0, 45.0)
		%Cursor.global_position.x = clampf(%Cursor.global_position.x, 385.0, 1535.0)
		%Cursor.global_position.y = clampf(%Cursor.global_position.y, 256.0, 824.0)
	else:
		# Not showing
		$GalaxyMap.hide()
		$GalaxyMapTitle.hide()
	# Ship action menu stuff
	if action_menu_showing:
		$ShipActionMenu.show()
		if Global.joystick_control:
			if Input.is_action_just_pressed("left1"):
				hovered_ship -= 1
			if Input.is_action_just_pressed("right1"):
				hovered_ship += 1
			if Input.is_action_just_pressed("down1"):
				hovered_ship += 4
			if Input.is_action_just_pressed("up1"):
				hovered_ship -= 4
			hovered_ship = clamp(hovered_ship, 0, main.get_node("FriendlyShips").get_child_count() - 1)
			if Input.is_action_just_pressed("left2"):
				hovered_target -= 1
			if Input.is_action_just_pressed("right2"):
				hovered_target += 1
			if Input.is_action_just_pressed("down2"):
				hovered_target += 4
			if Input.is_action_just_pressed("up2"):
				hovered_target -= 4
		for i in %ActionTargetShips/GridContainer.get_children():
			i.hide()
		for i in %ActionFriendlyShips/GridContainer.get_children():
			i.hide()
		var index: int = 0
		if targeting_mode == 1 or targeting_mode == 3 or targeting_mode == 5:
			var hostiles_count: int = main.get_node("HostileShips").get_child_count()
			if hostiles_count > 0:
				%ActionTargetShips/NoTargets.hide()
				hovered_target = clamp(hovered_target, 0, hostiles_count - 1)
				for ship in main.get_node("HostileShips").get_children():
					var box: Node = %ActionTargetShips/GridContainer.get_child(index)
					var stylebox: Resource = box.get_theme_stylebox("panel")
					box.get_node("Code").text = ship_codes[ship.type]
					if index == hovered_target:
						stylebox.border_color = Color8(100, 100, 160)
					else:
						stylebox.border_color = Color8(0, 0, 160)
					var friendly: Node = main.get_node("FriendlyShips").get_child(selected_ship)
					if friendly != null:
						if friendly.target != null:
							if index == friendly.target.get_index():
								stylebox.draw_center = true
							else:
								stylebox.draw_center = false
					box.show()
					index += 1
				if Input.is_action_just_pressed("A") and Global.joystick_control:
					main.get_node("FriendlyShips").get_child(selected_ship).new_target(hovered_target)
			else:
				%ActionTargetShips/NoTargets.show()
		elif targeting_mode == 4:
			%ActionTargetShips/NoTargets.hide()
			for ship in main.get_node("FriendlyShips").get_children():
				var box: Node = %ActionTargetShips/GridContainer.get_child(index)
				var stylebox: Resource = box.get_theme_stylebox("panel")
				box.get_node("Code").text = ship_codes[ship.type]
				if index == hovered_target:
					stylebox.border_color = Color8(100, 100, 160)
				else:
					stylebox.border_color = Color8(0, 0, 160)
				if index == main.get_node("FriendlyShips").get_child(selected_ship).target.get_index():
					stylebox.draw_center = true
				else:
					stylebox.draw_center = false
				box.show()
				index += 1
		elif targeting_mode == 7:
			pass # Select which drones to deploy
		index = 0
		for ship in main.get_node("FriendlyShips").get_children():
			var box: Node = %ActionFriendlyShips/GridContainer.get_child(index)
			var stylebox: Resource = box.get_theme_stylebox("panel")
			box.get_node("Code").text = ship_codes[ship.type]
			box.set_meta("type", ship.type)
			if index == hovered_ship:
				stylebox.border_color = Color8(160, 100, 100)
			else:
				stylebox.border_color = Color8(160, 0, 0)
			if index == selected_ship:
				stylebox.draw_center = true
			else:
				stylebox.draw_center = false
			box.show()
			index += 1
		if Input.is_action_just_pressed("1") and Global.joystick_control:
			selected_ship = hovered_ship
			targeting_mode = %ActionFriendlyShips/GridContainer.get_node("Ship" + str(selected_ship)).get_meta("type")
			%Instruction/Label.text = targeting_options[targeting_mode]
	else:
		$ShipActionMenu.hide()

# Sets up the dialogue box, with text and dialogue options
func dialogue_set_up(library: int, id: int) -> void:
	# Hide the options by default
	for child in %Options.get_children():
		child.hide()
	option_results = []
	# Warp in dialogue
	if library == 0:
		%DialogueText.text = warp_in_dialogue[id][1]
		max_option = len(warp_in_dialogue[id][2])
		# Options
		for i in max_option:
			%Options.get_node("Option" + str(i + 1)).text = str(i + 1) + ". " + warp_in_dialogue[id][2][i][0]
			option_results.append(warp_in_dialogue[id][2][i][1])
			%Options.get_node("Option" + str(i + 1)).show()
	# Response dialogue
	elif library == 1:
		%DialogueText.text = response_dialogue[id][0]
		max_option = len(response_dialogue[id][1])
		# Options
		for i in max_option:
			%Options.get_node("Option" + str(i + 1)).text = str(i + 1) + ". " + response_dialogue[id][1][i][0]
			option_results.append(response_dialogue[id][1][i][1])
			%Options.get_node("Option" + str(i + 1)).show()
	# Encounter win dialogue
	elif library == 2:
		%DialogueText.text = encounter_win_dialogue[id][0]
		max_option = len(encounter_win_dialogue[id][1])
		# Options
		for i in max_option:
			%Options.get_node("Option" + str(i + 1)).text = str(i + 1) + ". " + encounter_win_dialogue[id][1][i][0]
			option_results.append(encounter_win_dialogue[id][1][i][1])
			%Options.get_node("Option" + str(i + 1)).show()
	$Dialogue.show()
	dialogue_showing = true
	ready_to_select = true


func _galaxy_map() -> void:
	galaxy_map_showing = not galaxy_map_showing
	if galaxy_map_showing:
		if Global.galaxy_data[Global.current_system]["position"].x > 900:
			$GalaxyMap/Tokens.position.x = 600 - Global.galaxy_data[Global.current_system]["position"].x
		else:
			$GalaxyMap/Tokens.position.x = 45
		%Cursor.position = Global.galaxy_data[Global.current_system]["position"]


func _action_menu() -> void:
	action_menu_showing = not action_menu_showing


# Small interval before showing the warp in dialogue
func _on_warp_in_dialogue_timeout() -> void:
	# Search through options for the warp in dialogue and find which ones are
	# appropriate for this system
	var possible_dialogues: Array = []
	for i in warp_in_dialogue:
		if i[0] == main.system_properties:
			possible_dialogues.append(warp_in_dialogue.find(i))
	dialogue_set_up(0, possible_dialogues.pick_random())
	time_paused = true


# Called when either fuel or resources are spent or gained
func _quantity_change(quantity_type: int, up: bool) -> void:
	# Resources
	if quantity_type == 0:
		if up:
			%ResourcesLabel.add_theme_color_override("font_color", Color(0, 1, 0))
		else:
			%ResourcesLabel.add_theme_color_override("font_color", Color(1, 0, 0))
	# Fuel
	if quantity_type == 1:
		if up:
			%FuelLabel.add_theme_color_override("font_color", Color(0, 1, 0))
		else:
			%FuelLabel.add_theme_color_override("font_color", Color(1, 0, 0))


# Close the dialogue box
func close(combat: bool) -> void:
	$Dialogue.hide()
	dialogue_showing = false
	if combat:
		Global.in_combat = true
	else:
		main.warp_charge = 100.0


# Give the player resources from a dialogue event
func resources(n: int, resource_type: int = 0, dialogue: bool = false, response: int = 0, library: int = 1) -> void:
	if resource_type == 0:
		Global.resources += n
	elif resource_type == 1:
		Global.fuel += n
	if n >= 0:
		_quantity_change(resource_type, true)
	else:
		_quantity_change(resource_type, false)
	if dialogue:
		dialogue_set_up(library, response)


func select_dialogue(n: int) -> void:
	var args: Array = []
	if len(option_results[n - 1]) > 1:
		for i in len(option_results[n - 1]) - 1:
			args.append(option_results[n - 1][i + 1])
		callv(option_results[n - 1][0], args)
	else:
		call(option_results[n - 1][0])
	Engine.time_scale = 1.0
	time_paused = false


func hover_ship(n: int) -> void:
	hovered_ship = n


func select_ship(n: int) -> void:
	selected_ship = n
	targeting_mode = %ActionFriendlyShips/GridContainer.get_node("Ship" + str(selected_ship)).get_meta("type")
	%Instruction/Label.text = targeting_options[targeting_mode]


func hover_target(n: int) -> void:
	hovered_target = n


func select_target() -> void:
	main.get_node("FriendlyShips").get_child(selected_ship).new_target(hovered_target)


func win_encounter() -> void:
	resources(randi_range(1, 20))
	resources(randi_range(0, 4), 1, true, randi_range(0, len(encounter_win_dialogue) - 1), 2)


func lose() -> void:
	Global.playing = false
	galaxy_map_showing = false
	$GalaxyMap.hide()
	action_menu_showing = false
	$ShipActionMenu.hide()
	dialogue_set_up(1, 3)


func quit() -> void:
	get_tree().quit()


func restart() -> void:
	Global.new_game()
