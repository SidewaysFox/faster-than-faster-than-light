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
	"As you warp into the system, your fleet finds itself surrounded by a number of large wreckages. It looks like pirates must have found good prey in a convoy of freighters.",
	[["Scrap what's left of the freighter hulls.", ["resources", randi_range(5, 15), 0]]]
	],
	[[1],
	"As you warp into the system, your fleet finds itself surrounded by a number of large wreckages. It looks like pirates must have found good prey in a convoy of freighters.",
	[["Scrap what's left of the freighter hulls.", ["dialogue_set_up", 1, 1]]]
	],
	[[1],
	"As you warp into the system, your fleet finds itself surrounded by a number of large wreckages. It looks like pirates must have found good prey in a convoy of freighters.",
	[["Scrap what's left of the freighter hulls.", ["resources", randi_range(20, 40), 2]]]
	],
	[[1, "enemy presence"],
	"As your fleet exits warp, you're greeted by a radio transmission from an unknown starship fleet.\n\"Ahh... I see we've been blessed by the presence of a resource-rich fleet. We'll be taking that, thank you very much.\"\nAs communications are cut, the pirate fleet starts charging its weapons!",
	[["Get ready for combat.", ["close", true]]]
	],
	[[2],
	"As your fleet exits its jump, you see two stars locked in each others' orbits. You spend a moment taking a deep breath, before returning to your duties on deck.",
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
]


func _ready() -> void:
	$Dialogue.hide()
	$ScreenFade.show()
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
	%ResourcesLabel.text = "RSRC: " + str(Global.resources)
	%ResourcesLabel.add_theme_color_override("font_color", lerp(%ResourcesLabel.get_theme_color("font_color"), Color(1, 1, 1), 0.05))
	%FuelLabel.text = "FUEL: " + str(Global.fuel)
	%FuelLabel.add_theme_color_override("font_color", lerp(%FuelLabel.get_theme_color("font_color"), Color(1, 1, 1), 0.05))
	
	%ChargeProgress.value = main.warp_charge
	
	# Screen fade stuff
	$ScreenFade.color.a += fade_mode * delta
	$ScreenFade.color.a = clamp($ScreenFade.color.a, 0, 1)
	
	# Check if the dialogue is showing:
	if dialogue_showing:
		# Move selection up/down
		if Input.is_action_just_pressed("up1") or Input.is_action_just_pressed("up2"):
			current_dialogue_selection -= 1
		if Input.is_action_just_pressed("down1") or Input.is_action_just_pressed("down2"):
			current_dialogue_selection += 1
		current_dialogue_selection = clampi(current_dialogue_selection, 1, max_option)
		# Select
		if (Input.is_action_just_pressed("1") or Input.is_action_just_pressed("A")) and ready_to_select:
			var args: Array = []
			if len(option_results[current_dialogue_selection - 1]) > 1:
				for i in len(option_results[current_dialogue_selection - 1]) - 1:
					args.append(option_results[current_dialogue_selection - 1][i + 1])
				callv(option_results[current_dialogue_selection - 1][0], args)
			else:
				call(option_results[current_dialogue_selection - 1][0])
		# Appropriately colour the selected option
		for i in max_option:
			if i + 1 == current_dialogue_selection:
				%Options.get_node("Option" + str(i + 1)).add_theme_color_override("font_color", Color(0, 0.75, 1.0))
			else:
				%Options.get_node("Option" + str(i + 1)).add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
		%ChargeProgress/Label.text = "WAITING"
	# Show or hide the galaxy map
	elif (Input.is_action_just_pressed("4") or Input.is_action_just_pressed("D")) and main.warp_charge >= 100:
		galaxy_map_showing = not galaxy_map_showing
		if galaxy_map_showing:
			if Global.galaxy_data[Global.current_system]["position"].x > 900:
				$GalaxyMap/Tokens.position.x = 600 - Global.galaxy_data[Global.current_system]["position"].x
			else:
				$GalaxyMap/Tokens.position.x = 45
			%Cursor.position = Global.galaxy_data[Global.current_system]["position"]
	else:
		if main.warp_charge < 100:
			%ChargeProgress/Label.text = "WARP CHARGING"
		else:
			%ChargeProgress/Label.text = "WARP CHARGED"
	# Galaxy map stuff
	if galaxy_map_showing:
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
			if (Input.is_action_just_pressed("1") or Input.is_action_just_pressed("A")) and in_warp_range and closest_token[2] != Global.current_system and Global.fuel >= len(Global.fleet):
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


# Small interval before showing the warp in dialogue
func _on_warp_in_dialogue_timeout() -> void:
	# Search through options for the warp in dialogue and find which ones are
	# appropriate for this system
	var possible_dialogues: Array = []
	for i in warp_in_dialogue:
		if i[0] == main.system_properties:
			possible_dialogues.append(warp_in_dialogue.find(i))
	dialogue_set_up(0, possible_dialogues.pick_random())
	$Dialogue.show()
	dialogue_showing = true
	ready_to_select = true


# Called when either fuel or resources are spent or gained
func _quantity_change(quantity: int, up: bool) -> void:
	# Resources
	if quantity == 0:
		if up:
			%ResourcesLabel.add_theme_color_override("font_color", Color(0, 1, 0))
		else:
			%ResourcesLabel.add_theme_color_override("font_color", Color(1, 0, 0))
	# Fuel
	if quantity == 1:
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
func resources(n: int, response: int) -> void:
	Global.resources += n
	if n > 0:
		_quantity_change(0, true)
	else:
		_quantity_change(0, false)
	dialogue_set_up(1, response)
