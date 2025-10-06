extends Control


@onready var main: Node = get_node("/root/Space")
@export var galaxy_map_token: PackedScene
var intro_dialogue: bool = false
var fade_mode: int = -1
var cursor_speed: float = 250
var galaxy_map_showing: bool = false
var dialogue_showing: bool = true
var max_option: int = 3
var ready_to_select: bool = false
var current_dialogue_selection: int = 1
var option_results: Array
var action_menu_showing: bool = false
var info_menu_showing: bool = false
var shop_showing: bool = false
var hovered_ship: int = 0
var hovered_target: int = 0
var left_action_menu: bool = true
var selected_ship: int = 0
var targeting_mode: int = 0
var time_paused: bool = false
var hovered_at_ship_info: int = 0
var looking_at_ship_info: int = 0
var info_showing: int = 0
var warping = false
var prev_mouse_pos: Vector2
var item_catalogue = [0, 0, 0, 0]
var ship_catalogue = [[1, "ship name", "desc"], [1, "ship name", "desc"], [1, "ship name", "desc"]]
var hovered_shop_button: int = 0

var SHIP_CODES: Array[String] = ["CMND", "FGHT", "SHLD", "INFL", "REPR", "SCAN", "RLAY", "DRON"]
var TARGETING_OPTIONS: Array[String] = ["CANNOT TARGET", "TARGET", "CANNOT TARGET", "BOARD", "REPAIR", "MONITOR", "CANNOT TARGET", "DEPLOY"]
var ACTIVE_TEXT: Array[String] = ["CURRENTLY INACTIVE", "CURRENTLY ACTIVE"]
var MISC_TEXT: Array[String] = ["FLEET INVENTORY", "EQUIPPED WEAPONS", "N/A", "N/A", "N/A", "N/A", "N/A", "DEPLOYED DRONES"]

var control_tip_texts: Dictionary = {
	"AccessShop": ["ACCESS SHOP (B)", "ACCESS SHOP (B5)"],
	"ActionMenu": ["ACTION MENU (S)", "ACTION MENU (B2)"],
	"InfoMenu": ["INFO MENU (I)", "INFO MENU (B3)"],
	"GalaxyMap": ["GALAXY MAP (M)", "GALAXY MAP (B4)"],
	"PauseTime": ["PAUSE TIME (SPACE)", "PAUSE TIME (B5)"],
	"PauseGame": ["PAUSE GAME (ESC)", "PAUSE GAME (B6)"],
	"HideControlTips": ["HIDE CONTROLS (H)", "HIDE CONTROLS (B1)"],
	"ShowControlTips": ["SHOW CONTROLS (H)", "SHOW CONTROLS (B1)"],
}

var shop_ship_descriptions: Array[String] = [
	"A ship fresh from the foundry, a fitted with all the latest technologies. The crew seem eager for hire.",
	"Well used, but still reliable, this ship has seen better days - and wants to see more.",
	"A ship fresh from the foundry, but the crew don't seem that willing to put their lives on the line this early.",
	"An ancient model. Although it's been very thoroughly cleaned and maintained, you can't help but wonder how it's still going.",
	"Looks like it was born yesterday. You don't know how a ship could be \"born\", nor do you want to find out.",
	"This ship, although a commonly used model, seems to have been filled with personality by one of its more arty crews.",
	"It looks to be a very capable ship, but it has definitely been blown up and put back together before.",
	"Still has the original dealer's credentials on it. You have no idea how this dealer got hold of the ship.",
]

var warp_in_dialogue: Array = [ # Conditions, main text, [option, result]
	[[1, "tutorial", "enemy presence"],
	"Watch out! There are pirates in this system, and they'll engage you immediately. Don't panic, however. You are fortunately a quick-minded commander, and can temporarily stop time by pressing the pause time button.",
	[["Noted.", ["dialogue_set_up", 4, 6]]]
	],
	[[2, "tutorial", "enemy presence"],
	"Watch out! There are pirates in this system, and they'll engage you immediately. Don't panic, however. You are fortunately a quick-minded commander, and can temporarily stop time by pressing the pause time button.",
	[["Noted.", ["dialogue_set_up", 4, 6]]]
	],
	[[3, "tutorial", "enemy presence"],
	"Watch out! There are pirates in this system, and they'll engage you immediately. Don't panic, however. You are fortunately a quick-minded commander, and can temporarily stop time by pressing the pause time button.",
	[["Noted.", ["dialogue_set_up", 4, 6]]]
	],
	[[1, "tutorial", "shop presence"],
	"This star system has a shop present within it. You can initiate trade to purchase or sell weapons and starships in order to improve your fleet. Have a look around with the tech you have right now and see if you can afford anything.",
	[["OK.", ["close", false]]]
	],
	[[2, "tutorial", "shop presence"],
	"This star system has a shop present within it. You can initiate trade to purchase or sell weapons and starships in order to improve your fleet. Have a look around with the tech you have right now and see if you can afford anything.",
	[["OK.", ["close", false]]]
	],
	[[3, "tutorial", "shop presence"],
	"This star system has a shop present within it. You can initiate trade to purchase or sell weapons and starships in order to improve your fleet. Have a look around with the tech you have right now and see if you can afford anything.",
	[["OK.", ["close", false]]]
	],
	[[1, "tutorial", "destination"],
	"Well done for completing this short introductory course to Fatal Fleet.\nDon't forget - this is a difficult game. I hope you enjoy your journey through the galaxy.\nYou may redo this tutorial anytime from the main menu.",
	[["OK.", ["close", false, true]]]
	],
	[[2, "tutorial", "destination"],
	"Well done for completing this short introductory course to Fatal Fleet.\nDon't forget - this is a difficult game. I hope you enjoy your journey through the galaxy.\nYou may redo this tutorial anytime from the main menu.",
	[["OK.", ["close", false, true]]]
	],
	[[3, "tutorial", "destination"],
	"Well done for completing this short introductory course to Fatal Fleet.\nDon't forget - this is a difficult game. I hope you enjoy your journey through the galaxy.\nYou may redo this tutorial anytime from the main menu.",
	[["OK.", ["close", false, true]]]
	],
	[[1, "destination"],
	"You have finally arrived at your ultimate destination. Leading your fleet to the nearby Alliance outpost, you hail the personnel who await your arrival. Despite the challenges you and your crew have faced, you were successful in your mission.\nThank you for playing Fatal Fleet.",
	[["Complete the delivery.", ["close", false, true]]]
	],
	[[2, "destination"],
	"You have finally arrived at your ultimate destination. Leading your fleet to the nearby Alliance outpost, you hail the personnel who await your arrival. Despite the challenges you and your crew have faced, you were successful in your mission.\nThank you for playing Fatal Fleet.",
	[["Complete the delivery.", ["close", false, true]]]
	],
	[[3, "destination"],
	"You have finally arrived at your ultimate destination. Leading your fleet to the nearby Alliance outpost, you hail the personnel who await your arrival. Despite the challenges you and your crew have faced, you were successful in your mission.\nThank you for playing Fatal Fleet.",
	[["Complete the delivery.", ["close", false, true]]]
	],
	[[1],
	"As your fleet exits its jump, you take in the picturesque scenery around you.",
	[["Enjoy the view as your warp drives charge up once more.", ["close", false]]]
	],
	[[1],
	"You wait with bated breath, half expecting a pirate ambush as you exit warp, but none comes. You live another day.",
	[["Let's not wait around. Charge up the warp drives.", ["close", false]]]
	],
	[[1],
	"Although this system is devoid of anything of particular interest to your fleet, you can't help but remain apprehensive about your important task. In these distant reaches of space, it feels like everything wants you dead.",
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
	[["Scrap what's left of the freighter hulls.", ["resources", randi_range(10, 25), 0, true, 0, 1]], ["Leave it alone for now.", ["close", false]]]
	],
	[[1],
	"As you warp into the system, your fleet finds itself surrounded by a number of large wreckages. It looks like pirates must have found good prey in a convoy of freighters.",
	[["Scrap what's left of the freighter hulls.", ["dialogue_set_up", 1, 1]], ["Leave it alone for now.", ["close", false]]]
	],
	[[1],
	"As you warp into the system, your fleet finds itself surrounded by a number of large wreckages. It looks like pirates must have found good prey in a convoy of freighters.",
	[["Scrap what's left of the freighter hulls.", ["resources", randi_range(25, 40), 0, true, 2, 1]], ["Leave it alone for now.", ["close", false]]]
	],
	[[1],
	"As you warp into the system, your fleet finds itself surrounded by a number of large wreckages. It looks like pirates must have found good prey in a convoy of freighters.",
	[["Scrap what's left of the freighter hulls.", ["resources", randi_range(3, 16), 1, true, 4, 1]], ["Leave it alone for now.", ["close", false]]]
	],
	[[1, "enemy presence"],
	"As your fleet exits warp, you're greeted by a radio transmission from an unknown starship fleet.\n\"Ahh... I see we've been blessed by the presence of a resource-rich fleet. We'll be taking that, thank you very much.\"\nAs communications are cut, the pirate fleet starts charging its weapons!",
	[["Get ready for combat.", ["close", true]]]
	],
	[[1, "shop presence"],
	"As your fleet exits warp, you're set on edge as you're hailed by a lone starship.\n\"Hello! Nice to see a friendly face around here. Care to see my wares?\"\nYou ease up - they seem harmless enough.",
	[["Return friendly communications.", ["close", false]]]
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
	[[2, "shop presence"],
	"As your fleet exits warp, you're set on edge as you're hailed by a lone starship.\n\"Hello! Nice to see a friendly face around here. Care to see my wares?\"\nYou ease up - they seem harmless enough.",
	[["Return friendly communications.", ["close", false]]]
	],
	[[3],
	"As your fleet exits its jump, you are surprised to find you and your fleet amongst a trinary star system, a rare sight for anyone not part of the navy.",
	[["Enjoy the view as your warp drives charge up once more.", ["close", false]]]
	],
	[[3, "enemy presence"],
	"As your fleet exits warp, you're greeted by a radio transmission from an unknown starship fleet.\n\"Ahh... I see we've been blessed by the presence of a resource-rich fleet - in a trinary system too! We'll be taking that, thank you very much.\"\nAs communications are cut, the pirate fleet starts charging its weapons!",
	[["Get ready for combat.", ["close", true]]]
	],
	[[3, "shop presence"],
	"As your fleet exits warp, you're set on edge as you're hailed by a lone starship.\n\"Hello! Nice to see a friendly face around here. It's quite an attractive spot but I still don't get much traffic through here. Care to see my wares?\"\nYou ease up - they seem harmless enough.",
	[["Return friendly communications.", ["close", false]]]
	],
	[[1, "star proximity"],
	"As you exit warp, you realise you've ended up dangerously close to this system's star. Your ships could be in danger if you linger for too long.",
	[["Hope the star doesn't flare up while you wait for your warp drives to charge.", ["close", false]]]
	],
	[[1, "enemy presence", "star proximity"],
	"Your fleet exits warp, and you realise that you're uncomfortably close to a star. Suddenly, your systems warn you of a nearby threat. A pirate fleet either unaware or uncaring of the danger slides into view.",
	[["Hope that the star doesn't pose too much of an issue and get ready for combat.", ["close", true]]]
	],
	[[1, "shop presence", "star proximity"],
	"As your fleet exits warp, you're set on edge as you're hailed by a lone starship, close to the nearby star.\n\"Ho, there! I'm a travelling merchant - I can shield us from the star, if you're willing to take a gander at what I have.\"\nYou decide it could be worth a look.",
	[["Return friendly communications.", ["close", false]]]
	],
	[[2, "star proximity"],
	"The binary system of stars you've just warped into makes it hard to miss the fact that you've come in far too close for comfort to one of them.",
	[["Hope the star doesn't flare up while you wait for your warp drives to charge.", ["close", false]]]
	],
	[[2, "enemy presence", "star proximity"],
	"Your fleet exits warp, and you realise that you're uncomfortably close to a star. Suddenly, your systems warn you of a nearby threat. A pirate fleet either unaware or uncaring of the danger slides into view.",
	[["Hope that the star doesn't pose too much of an issue and get ready for combat.", ["close", true]]]
	],
	[[2, "shop presence", "star proximity"],
	"As your fleet exits warp, you're set on edge as you're hailed by a lone starship, close to the nearby star.\n\"Ho, there! I'm a travelling merchant - I can shield us from the star, if you're willing to take a gander at what I have.\"\nYou decide it could be worth a look.",
	[["Return friendly communications.", ["close", false]]]
	],
	[[3, "star proximity"],
	"You find yourself and your fleet in a trinary system, but your close proximity to one of the stars unfortunately means you cannot affort to take in the view.",
	[["Hope the star doesn't flare up while you wait for your warp drives to charge.", ["close", false]]]
	],
	[[3, "enemy presence", "star proximity"],
	"Your fleet exits warp, and you realise that you're uncomfortably close to a star. Suddenly, your systems warn you of a nearby threat. A pirate fleet either unaware or uncaring of the danger slides into view.",
	[["Hope that the star doesn't pose too much of an issue and get ready for combat.", ["close", true]]]
	],
	[[3, "shop presence", "star proximity"],
	"As your fleet exits warp, you're set on edge as you're hailed by a lone starship, close to the nearby star.\n\"Ho, there! I'm a travelling merchant - I can shield us from the star, if you're willing to take a gander at what I have.\"\nYou decide it could be worth a look.",
	[["Return friendly communications.", ["close", false]]]
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
	[["Try once more.", ["restart"]], ["Give up.", ["quit_to_menu"]]]
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

var intro_dialogues: Array = [
	["You, as an Alliance fleet commander, have been tasked with a crucial mission: deliver a package of goods and weapons to an isolated Alliance navy, who are currently fighting against the rebel uprising. The region of space ahead is outside of policed Alliance territory and is rife with pirates and other threats. In the rush to respond to the sudden rebel presence, you were only able to mobilise a small squadron of starships.\nMake the delivery, and save millions of lives.\nThe rest is up to you.",
	[["Let's go.", ["close", false]]]
	],
	["Welcome, commander, to Fatal Fleet! You have been given authority of a small fleet of ships, and are expected to be able to adequately lead those ships through the cosmos.\nIn this tutorial, you will learn the ropes of fleet command, including the basics of combat.",
	[["Continue", ["dialogue_set_up", 4, 0]]]
	],
]

var tutorial_dialogues: Array = [
	["First and foremost, the right side of your interface shows your controls and their related keyboard shortcuts. You can hide or show this at will.\nAt the top of your interface, you can see how much \"tech\" (galactic currency) you currently have, as well as how much fuel you have ready to use. Each ship in your fleet requires one fuel canister to jump between star systems. The bar to the right of that displays your fleet's current warp charge progress. You will not be able to travel to another system until your warp drives have finished charging.\nYou can hide the entire interface at any time by holding \"~\".",
	[["OK.", ["dialogue_set_up", 4, 1]], ["Back", ["dialogue_set_up", 3, 1]]]
	],
	["A crucial part of your toolset is the Fleet Information Menu. This panel can be accessed by pressing the Info Menu button and contains useful data about the starships in your fleet. You can also give instructions to them, upgrade them or possibly change up their equipment.",
	[["OK.", ["dialogue_set_up", 4, 2]], ["Back", ["dialogue_set_up", 4, 0]]]
	],
	["Speaking of starships, there are eight different types you should know about.\nCMND: Command Ship - Your fleet's flagship, within which you are seated. It is imperative that you protect this ship.\nFGHT: Fighter - Engages with and destroys threats as instructed by you. You can change which weapons it uses in the Fleet Info Menu.\nSHLD: Shield Ship: Protects your fleet from incoming projectiles. Can be bypassed by some projectiles and will need to recharge upon successfully blocking one.",
	[["Continue", ["dialogue_set_up", 4, 3]], ["Back", ["dialogue_set_up", 4, 1]]]
	],
	["INFL - Infiltration Ship: Teleports troops onto enemy starships to temporarily disable them.\nREPR - Repair Ship: Gradually repairs your starships' hulls in and out of combat.\nSCAN - Scanner Ship: Scans enemy starships, revealing information about them and searching for weak spots.",
	[["Continue", ["dialogue_set_up", 4, 4]], ["Back", ["dialogue_set_up", 4, 2]]]
	],
	["RLAY - Relay Ship: Boosts your warp drive charge rate and increases the distance you can travel in one jump.\nDRON - Drone Command Ship: Deploys drones to autonomously aid you in battle. Can operate fighter or repair drones, depending on its upgrade level.",
	[["OK.", ["dialogue_set_up", 4, 5]], ["Back", ["dialogue_set_up", 4, 3]]]
	],
	["That's all for now. Have a play around with the menus and, when ready, open the Galaxy Map with the Galaxy Map button to warp to the next system.",
	[["OK.", ["close", false]], ["Back", ["dialogue_set_up", 4, 4]]]
	],
	["After pausing time, open the Ship Action Menu with the Action Menu button to give each of your ships a target to focus on.\nRepair ships will focus on starships within your own fleet.",
	[["OK.", ["close", true]]]
	],
]


func _ready() -> void:
	$Dialogue.hide()
	$ScreenFade.show()
	%Gameplay/ControlMode.button_pressed = Global.joystick_control
	%Gameplay/JoystickMode.button_pressed = Global.dual_joysticks
	if Global.initialising:
		intro_dialogue = true
		await main.setup_complete
	# Generate visual galaxy map
	for i in Global.galaxy_data:
		var new_token: Node = galaxy_map_token.instantiate()
		new_token.id = i["id"]
		new_token.position = i["position"]
		$GalaxyMap/Tokens.add_child(new_token)
	if not Global.controls_showing:
		_hide_controls()


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
	
	if (Input.is_action_just_pressed("action menu") and not Global.joystick_control) or (Global.joystick_control and (Input.is_action_just_pressed("2") or Input.is_action_just_pressed("B"))):
		_action_menu()
	
	if (Input.is_action_just_pressed("info menu") and not Global.joystick_control) or (Global.joystick_control and (Input.is_action_just_pressed("3") or Input.is_action_just_pressed("C"))):
		_info_menu()
	
	if (Input.is_action_just_pressed("galaxy map") and not Global.joystick_control) or (Global.joystick_control and (Input.is_action_just_pressed("4") or Input.is_action_just_pressed("D"))):
		_galaxy_map()
	
	if (Input.is_action_just_pressed("time pause") and not Global.joystick_control) or (Global.joystick_control and (Input.is_action_just_pressed("5") or Input.is_action_just_pressed("E")) and "shop presence" not in main.system_properties):
		_time_pause()
	
	if (Input.is_action_just_pressed("shop") and not Global.joystick_control) or (Global.joystick_control and (Input.is_action_just_pressed("5") or Input.is_action_just_pressed("E"))):
		_shop()
	
	if ((Input.is_action_just_pressed("pause") and not Global.joystick_control) or (Global.joystick_control and (Input.is_action_just_pressed("6") or Input.is_action_just_pressed("F")))) and not warping:
		_pause()
	
	if (Input.is_action_just_pressed("hide controls") and not Global.joystick_control) or (Global.joystick_control and (Input.is_action_just_pressed("1") or Input.is_action_just_pressed("A"))):
		_hide_controls()
	
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
		else:
			# Check for numerical inputs
			for i in max_option:
				if Input.is_action_just_pressed(str(i + 1)):
					%Options.get_node("Option" + str(i + 1)).emit_signal("pressed")
		%ChargeProgress/Label.text = "WAITING"
	else:
		if main.warp_charge < 100:
			%ChargeProgress/Label.text = "WARP CHARGING"
		else:
			%ChargeProgress/Label.text = "WARP CHARGED"
	
	for tip in $ControlTips/VBoxContainer/Main.get_children():
		tip.get_child(0).text = control_tip_texts[tip.name][int(Global.joystick_control)]
	if Global.controls_showing:
		$ControlTips/VBoxContainer/HideControlTips/Button.text = control_tip_texts["HideControlTips"][int(Global.joystick_control)]
	else:
		$ControlTips/VBoxContainer/HideControlTips/Button.text = control_tip_texts["ShowControlTips"][int(Global.joystick_control)]
	
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
		$GalaxyMapControls.show()
		# Left/right scrolling
		if Input.is_action_pressed("right2"):
			$GalaxyMap/Tokens.position.x -= 400 * delta * Global.joystick_sens
		if Input.is_action_pressed("left2"):
			$GalaxyMap/Tokens.position.x += 400 * delta * Global.joystick_sens
		%Cursor.position += Vector2(Input.get_axis("left1", "right1"), Input.get_axis("up1", "down1")).normalized() * cursor_speed * Global.joystick_sens * delta
		# Move the map cursor if the mouse is detected to be moving
		if get_global_mouse_position() != prev_mouse_pos and not Global.joystick_control:
			%Cursor.global_position = get_global_mouse_position()
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
				if "shop presence" in main.system_properties:
					Global.galaxy_data[Global.current_system]["item shop"] = item_catalogue
					Global.galaxy_data[Global.current_system]["ship shop"] = ship_catalogue
				Engine.time_scale = 1.0
				warping = true
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
		$GalaxyMapControls.hide()
	
	# Ship action menu stuff
	if action_menu_showing:
		$ShipActionMenu.show()
		if Global.joystick_control:
			if Global.dual_joysticks:
				if Input.is_action_just_pressed("left1"):
					hovered_ship -= 1
				if Input.is_action_just_pressed("right1"):
					hovered_ship += 1
				if Input.is_action_just_pressed("down1"):
					hovered_ship += 4
				if Input.is_action_just_pressed("up1"):
					hovered_ship -= 4
				if Input.is_action_just_pressed("left2"):
					hovered_target -= 1
				if Input.is_action_just_pressed("right2"):
					hovered_target += 1
				if Input.is_action_just_pressed("down2"):
					hovered_target += 4
				if Input.is_action_just_pressed("up2"):
					hovered_target -= 4
			elif left_action_menu:
				if Input.is_action_just_pressed("left1"):
					if hovered_ship == 0 or hovered_ship == 4:
						left_action_menu = false
					else:
						hovered_ship -= 1
				if Input.is_action_just_pressed("right1"):
					if hovered_ship == 3 or hovered_ship == 7:
						left_action_menu = false
					else:
						hovered_ship += 1
				if Input.is_action_just_pressed("down1"):
					hovered_ship += 4
				if Input.is_action_just_pressed("up1"):
					hovered_ship -= 4
			elif not left_action_menu:
				if Input.is_action_just_pressed("left1"):
					if hovered_target == 0 or hovered_target == 4:
						left_action_menu = true
					else:
						hovered_target -= 1
				if Input.is_action_just_pressed("right1"):
					if hovered_target == 3 or hovered_target == 7:
						left_action_menu = true
					else:
						hovered_target += 1
				if Input.is_action_just_pressed("down1"):
					hovered_target += 4
				if Input.is_action_just_pressed("up1"):
					hovered_target -= 4
			hovered_ship = clamp(hovered_ship, 0, main.get_node("FriendlyShips").get_child_count() - 1)
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
					box.get_node("Code").text = SHIP_CODES[ship.type]
					if index == hovered_target and ((Global.joystick_control and not Global.dual_joysticks and not left_action_menu) or not Global.joystick_control):
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
				box.get_node("Code").text = SHIP_CODES[ship.type]
				if index == hovered_target and ((Global.joystick_control and not Global.dual_joysticks and not left_action_menu) or not Global.joystick_control):
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
		elif targeting_mode == 7:
			pass # Select which drones to deploy
		index = 0
		for ship in main.get_node("FriendlyShips").get_children():
			var box: Node = %ActionFriendlyShips/GridContainer.get_child(index)
			var stylebox: Resource = box.get_theme_stylebox("panel")
			box.get_node("Code").text = SHIP_CODES[ship.type]
			box.set_meta("type", ship.type)
			if index == hovered_ship and ((Global.joystick_control and not Global.dual_joysticks and left_action_menu) or not Global.joystick_control):
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
			%Instruction/Label.text = TARGETING_OPTIONS[targeting_mode]
	else:
		$ShipActionMenu.hide()
	
	if info_menu_showing:
		$FleetInfoMenu.show()
		var index: int = 0
		var fleet_size = main.get_node("FriendlyShips").get_child_count()
		for button in %ShipSelection.get_children():
			if index < fleet_size:
				var ship: Node = main.get_node("FriendlyShips").get_child(index)
				button.show()
				button.get_child(0).text = SHIP_CODES[ship.type] + ": " + ship.ship_name.to_upper()
				var stylebox: Resource = button.get_theme_stylebox("panel")
				if index == hovered_at_ship_info:
					stylebox.border_color = Color8(160, 100, 100)
				else:
					stylebox.border_color = Color8(160, 0, 0)
				if index == looking_at_ship_info:
					stylebox.draw_center = true
					%Information/General/HullStrength/Label.text = "HULL STRENGTH: " + str(ship.hull_strength)
					%Information/General/Hull/Label.text = "CURRENT HULL: " + str(ship.hull)
					%Information/General/Agility/Label.text = "AGILITY: " + str(ship.agility * 100) + "%"
					%Information/General/Status/Label.text = "STATUS: OK"
					%Information/Leveling/CurrentLevel/Label.text = "CURRENT LEVEL: " + str(ship.level)
					if ship.level < 3 and not Global.in_combat:
						%Information/Leveling/Cost/Label.text = "UPGRADE COST: " + str(Global.upgrade_costs[ship.type][ship.level - 1])
						%Information/Leveling/Specification0/Label.text = Global.upgrade_specifications[ship.type][ship.level - 1][0]
						%Information/Leveling/Specification1/Label.text = Global.upgrade_specifications[ship.type][ship.level - 1][1]
						%Information/Leveling/Specification2/Label.text = Global.upgrade_specifications[ship.type][ship.level - 1][2]
						%Information/Leveling/Cost.show()
						%Information/Leveling/Upgrade.show()
						%Information/Leveling/WhenUpgraded.show()
						%Information/Leveling/Specification0.show()
						%Information/Leveling/Specification1.show()
						%Information/Leveling/Specification2.show()
					else:
						%Information/Leveling/Cost.hide()
						%Information/Leveling/Upgrade.hide()
						%Information/Leveling/WhenUpgraded.hide()
						%Information/Leveling/Specification0.hide()
						%Information/Leveling/Specification1.hide()
						%Information/Leveling/Specification2.hide()
					%Information/Instructions/Active/Label.text = ACTIVE_TEXT[int(ship.active)]
					%Information/Instructions/TakeAction/Button.text = Global.ship_actions[ship.type][0]
					%Information/Instructions/CeaseAction/Button.text = Global.ship_actions[ship.type][1]
					%Information/Misc/RelatedStat/Label.text = MISC_TEXT[ship.type]
					for child in %MiscMenu.get_children():
						child.hide()
					if ship.type == 0:
						%Information/Misc/RelatedStat2.show()
						%MiscMenu/CommandShip.show()
						%Information/Misc/RelatedStat2/Label.text = "INVENTORY CAPACITY: " + str(Global.max_inventory)
						for child in %MiscMenu/CommandShip.get_children():
							child.hide()
						var child_index: int = 0
						for item in Global.fleet_inventory:
							%MiscMenu/CommandShip.get_child(child_index).show()
							%MiscMenu/CommandShip.get_child(child_index).get_node("Labels/Name").text = " ITEM: " + Global.weapon_list[item]["Name"]
							%MiscMenu/CommandShip.get_child(child_index).get_node("Labels/Type").text = " TYPE: " + Global.weapon_types[Global.weapon_list[item]["Type"]]
							%MiscMenu/CommandShip.get_child(child_index).get_node("Labels/Value").text = " VALUE: " + str(Global.weapon_list[item]["Cost"]) + " TECH"
							child_index += 1
					elif ship.type == 1:
						%Information/Misc/RelatedStat2.show()
						%MiscMenu/Fighter.show()
						%Information/Misc/RelatedStat2/Label.text = "WEAPON SLOTS: " + str(ship.level)
						for child in %MiscMenu/Fighter.get_children():
							child.hide()
						var child_index: int = 0
						for weapon in ship.weapons:
							%MiscMenu/Fighter.get_child(child_index).show()
							%MiscMenu/Fighter.get_child(child_index + 1).show()
							%MiscMenu/Fighter.get_child(child_index).get_node("HBoxContainer/Label").text = Global.weapon_list[weapon]["Name"]
							%MiscMenu/Fighter.get_child(child_index + 1).get_node("Labels/Type").text = " TYPE: " + str(Global.weapon_types[Global.weapon_list[weapon]["Type"]])
							%MiscMenu/Fighter.get_child(child_index + 1).get_node("Labels/Damage").text = " DAMAGE: " + str(Global.weapon_list[weapon]["Damage"])
							%MiscMenu/Fighter.get_child(child_index + 1).get_node("Labels/Reload").text = " RELOAD: " + str(Global.weapon_list[weapon]["Reload time"])
							child_index += 2
					else:
						%Information/Misc/RelatedStat2.hide()
				else:
					stylebox.draw_center = false
				
				for tab in %Information.get_children():
					if tab.get_index() == info_showing:
						tab.show()
					else:
						tab.hide()
			else:
				button.hide()
			index += 1
		looking_at_ship_info = clampi(looking_at_ship_info, 0, main.get_node("FriendlyShips").get_child_count() - 1)
	else:
		$FleetInfoMenu.hide()
	
	if shop_showing:
		$Shop.show()
		
		# Item buying UI
		for child in %ItemBuy.get_children():
			var index: int = child.get_index()
			if index > 0:
				child.hide()
				var stylebox: Resource = child.get_theme_stylebox("panel")
				if index == hovered_shop_button:
					stylebox.border_color = Color8(160, 100, 100)
				else:
					stylebox.border_color = Color8(160, 0, 0)
		var child_index: int = 1
		for item in item_catalogue:
			%ItemBuy.get_child(child_index).show()
			%ItemBuy.get_child(child_index).get_node("Row/Col1/Name").text = " NAME: " + Global.weapon_list[item]["Name"]
			%ItemBuy.get_child(child_index).get_node("Row/Col1/Type").text = " TYPE: " + Global.weapon_types[Global.weapon_list[item]["Type"]]
			%ItemBuy.get_child(child_index).get_node("Row/Col1/Damage").text = " DAMAGE: " + str(Global.weapon_list[item]["Damage"]) + " HULL"
			%ItemBuy.get_child(child_index).get_node("Row/Col1/Reload").text = " RELOAD: " + str(Global.weapon_list[item]["Reload time"]) + " SECONDS"
			%ItemBuy.get_child(child_index).get_node("Row/Col1/Value").text = " VALUE: " + str(Global.weapon_list[item]["Cost"]) + " TECH"
			%ItemBuy.get_child(child_index).get_node("Row/Col2/Text").text = Global.weapon_list[item]["Description"]
			child_index += 1
		
		# Item selling UI
		for child in %ItemSell.get_children():
			var index: int = child.get_index()
			if index > 0:
				child.hide()
				var stylebox: Resource = child.get_theme_stylebox("panel")
				if index + %ItemBuy.get_child_count() == hovered_shop_button:
					stylebox.border_color = Color8(100, 100, 160)
				else:
					stylebox.border_color = Color8(0, 0, 160)
		child_index = 1
		for item in Global.fleet_inventory:
			%ItemSell.get_child(child_index).show()
			%ItemSell.get_child(child_index).get_node("Row/Col1/Name").text = " NAME: " + Global.weapon_list[item]["Name"]
			%ItemSell.get_child(child_index).get_node("Row/Col1/Type").text = " TYPE: " + Global.weapon_types[Global.weapon_list[item]["Type"]]
			%ItemSell.get_child(child_index).get_node("Row/Col1/Value").text = " SELL VALUE: " + str((ceil(Global.weapon_list[item]["Cost"]) / 2)) + " TECH"
			%ItemSell.get_child(child_index).get_node("Row/Col2/Damage").text = " DAMAGE: " + str(Global.weapon_list[item]["Damage"]) + " HULL"
			%ItemSell.get_child(child_index).get_node("Row/Col2/Reload").text = " RELOAD: " + str(Global.weapon_list[item]["Reload time"]) + " SECONDS"
			child_index += 1
		
		# Ship buying UI
		for child in %ShipBuy.get_children():
			var index: int = child.get_index()
			if index > 0:
				child.hide()
				var stylebox: Resource = child.get_theme_stylebox("panel")
				if index == hovered_shop_button:
					stylebox.border_color = Color8(160, 100, 100)
				else:
					stylebox.border_color = Color8(160, 0, 0)
		child_index = 1
		for ship in ship_catalogue:
			%ShipBuy.get_child(child_index).show()
			%ShipBuy.get_child(child_index).get_node("Row/Col1/Name").text = " NAME: " + ship[1]
			%ShipBuy.get_child(child_index).get_node("Row/Col1/Type").text = " TYPE: " + SHIP_CODES[ship[0]]
			%ShipBuy.get_child(child_index).get_node("Row/Col1/Value").text = " VALUE: " + str(Global.starship_base_stats[ship[0]]["Cost"]) + " TECH"
			%ShipBuy.get_child(child_index).get_node("Row/Col2/Text").text = ship[2]
			child_index += 1
		
		# Ship selling UI
		for child in %ShipSell.get_children():
			var index: int = child.get_index()
			if index > 0:
				child.hide()
				var stylebox: Resource = child.get_theme_stylebox("panel")
				if index + %ShipBuy.get_child_count() == hovered_shop_button:
					stylebox.border_color = Color8(100, 100, 160)
				else:
					stylebox.border_color = Color8(0, 0, 160)
		child_index = 1
		for ship in main.get_node("FriendlyShips").get_children():
			if ship.type == 0:
				continue
			%ShipSell.get_child(child_index).show()
			%ShipSell.get_child(child_index).get_node("Row/Col1/Name").text = " NAME: " + ship.ship_name
			%ShipSell.get_child(child_index).get_node("Row/Col1/Type").text = " TYPE: " + SHIP_CODES[ship.type]
			%ShipSell.get_child(child_index).get_node("Row/Col2/Level").text = " LEVEL: " + str(ship.level)
			%ShipSell.get_child(child_index).get_node("Row/Col2/Value").text = " SELL VALUE: " + str((ceil(Global.starship_base_stats[ship.type]["Cost"]) / 2) * ship.level) + " TECH"
			child_index += 1
	else:
		$Shop.hide()
	
	prev_mouse_pos = get_global_mouse_position()

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
	# Intro dialogue
	elif library == 3:
		%DialogueText.text = intro_dialogues[id][0]
		max_option = len(intro_dialogues[id][1])
		# Options
		for i in max_option:
			%Options.get_node("Option" + str(i + 1)).text = str(i + 1) + ". " + intro_dialogues[id][1][i][0]
			option_results.append(intro_dialogues[id][1][i][1])
			%Options.get_node("Option" + str(i + 1)).show()
	elif library == 4:
		%DialogueText.text = tutorial_dialogues[id][0]
		max_option = len(tutorial_dialogues[id][1])
		# Options
		for i in max_option:
			%Options.get_node("Option" + str(i + 1)).text = str(i + 1) + ". " + tutorial_dialogues[id][1][i][0]
			option_results.append(tutorial_dialogues[id][1][i][1])
			%Options.get_node("Option" + str(i + 1)).show()
	$Dialogue.show()
	dialogue_showing = true
	ready_to_select = true


func _galaxy_map() -> void:
	if not action_menu_showing and not info_menu_showing and not dialogue_showing and not shop_showing and main.warp_charge >= 100 and not warping:
		galaxy_map_showing = not galaxy_map_showing
		if galaxy_map_showing:
			if Global.galaxy_data[Global.current_system]["position"].x > 900:
				$GalaxyMap/Tokens.position.x = 600 - Global.galaxy_data[Global.current_system]["position"].x
			else:
				$GalaxyMap/Tokens.position.x = 45
			%Cursor.position = Global.galaxy_data[Global.current_system]["position"]


func _action_menu() -> void:
	if not galaxy_map_showing and not info_menu_showing and not dialogue_showing and not shop_showing and not warping:
		action_menu_showing = not action_menu_showing


func _time_pause() -> void:
	if not galaxy_map_showing and not dialogue_showing and not warping:
		time_paused = not time_paused


func _pause() -> void:
	$PauseMenu.show()
	$PauseMenu/UnpauseTimer.start()
	get_tree().paused = true


func _info_menu() -> void:
	if not galaxy_map_showing and not action_menu_showing and not dialogue_showing and not shop_showing and not warping:
		info_menu_showing = not info_menu_showing


func upgrade_ship() -> void:
	var ship: Node = main.get_node("FriendlyShips").get_child(looking_at_ship_info)
	var price: int = Global.upgrade_costs[ship.type][ship.level - 1]
	if Global.resources >= price:
		resources(-price)
		# I can't really think of a good, efficient and easily editable way to do this
		if ship.type == 0:
			ship.hull_strength += 5
			ship.hull += 5
			ship.agility += 0.05
			Global.max_inventory += 1
		elif ship.type == 1:
			if ship.level == 1:
				ship.hull_strength += 2
				ship.hull += 2
				ship.agility += 0.05
			elif ship.level == 2:
				ship.hull_strength += 4
				ship.hull += 4
				ship.agility += 0.1
			ship.weapons.append(0)
		elif ship.type == 2:
			ship.agility += 0.05
			if ship.level == 1:
				ship.hull_strength += 2
				ship.hull += 2
			elif ship.level == 2:
				ship.hull_strength += 3
				ship.hull += 3
		elif ship.type == 3:
			ship.agility += 0.05
			if ship.level == 1:
				ship.hull_strength += 2
				ship.hull += 2
			elif ship.level == 2:
				ship.hull_strength += 5
				ship.hull += 5
		elif ship.type == 4:
			if ship.level == 1:
				ship.hull_strength += 1
				ship.hull += 1
				ship.agility += 0.05
			elif ship.level == 2:
				ship.hull_strength += 2
				ship.hull += 2
		elif ship.type == 5:
			ship.hull_strength += 1
			ship.hull += 1
			if ship.level == 1:
				ship.agility += 0.05
			elif ship.level == 2:
				ship.agility += 0.1
		elif ship.type == 6:
			ship.agility += 0.05
			if ship.level == 1:
				ship.hull_strength += 1
				ship.hull += 1
			elif ship.level == 2:
				ship.hull_strength += 2
				ship.hull += 2
		elif ship.type == 7:
			ship.hull_strength += 4
			ship.hull += 4
			if ship.level == 1:
				ship.drone_slots.append(0)
			elif ship.level == 2:
				ship.drone_slots.append_array([0, 0])
		ship.level += 1
		ship.stats_update()


func _on_shop_setup_timeout() -> void:
	# Set up the shop, if there is one
	if "shop presence" in main.system_properties:
		if Global.current_system in Global.visited_systems:
			item_catalogue = Global.galaxy_data[Global.current_system]["item shop"]
			ship_catalogue = Global.galaxy_data[Global.current_system]["ship shop"]
		else:
			$ControlTips/VBoxContainer/Main/AccessShop.show()
			for item in len(item_catalogue):
				item_catalogue[item] = randi_range(0, len(Global.weapon_list) - 1)
			for ship in len(ship_catalogue):
				ship_catalogue[ship][0] = randi_range(1, 7)
				ship_catalogue[ship][1] = Global.possible_names.pop_at(randi_range(0, len(Global.possible_names) - 1))
				ship_catalogue[ship][2] = shop_ship_descriptions.pick_random()


func _shop() -> void:
	if not galaxy_map_showing and not action_menu_showing and not info_menu_showing and not dialogue_showing and not warping and "shop presence" in main.system_properties:
		shop_showing = not shop_showing


func _hide_controls() -> void:
	if not Global.joystick_control or (Global.joystick_control and not action_menu_showing and not info_menu_showing and not galaxy_map_showing and not dialogue_showing and not shop_showing):
		$ControlTips/VBoxContainer/Main.visible = not $ControlTips/VBoxContainer/Main.visible
		if $ControlTips/VBoxContainer/Main.visible:
			Global.controls_showing = true
		else:
			Global.controls_showing = false


func _item_shop() -> void:
	$Shop/VBoxContainer/HBoxContainer/ShipShop.hide()
	$Shop/VBoxContainer/HBoxContainer/ItemShop.show()


func _ship_shop() -> void:
	$Shop/VBoxContainer/HBoxContainer/ItemShop.hide()
	$Shop/VBoxContainer/HBoxContainer/ShipShop.show()


# Small interval before showing the warp in dialogue
func _on_warp_in_dialogue_timeout() -> void:
	if Global.current_system in Global.visited_systems:
		if intro_dialogue:
			if Global.tutorial:
				dialogue_set_up(3, 1)
			else:
				dialogue_set_up(3, 0)
			time_paused = true
			intro_dialogue = false
		else:
			close(Global.galaxy_data[Global.current_system]["enemy presence"])
	else:
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
func close(combat: bool, end: bool = false) -> void:
	$Dialogue.hide()
	dialogue_showing = false
	time_paused = false
	if combat:
		Global.in_combat = true
	else:
		main.warp_charge = 100.0
	if end:
		quit_to_menu()


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


func hover_ship(n: int) -> void:
	hovered_ship = n


func select_ship(n: int) -> void:
	selected_ship = n
	targeting_mode = %ActionFriendlyShips/GridContainer.get_node("Ship" + str(selected_ship)).get_meta("type")
	%Instruction/Label.text = TARGETING_OPTIONS[targeting_mode]


func hover_target(n: int) -> void:
	hovered_target = n


func select_target() -> void:
	if main.get_node("FriendlyShips").get_child(selected_ship) != null:
		main.get_node("FriendlyShips").get_child(selected_ship).new_target(hovered_target)


func hover_info(n: int) -> void:
	hovered_at_ship_info = n


func select_info(n: int) -> void:
	looking_at_ship_info = n


func hover_shop(n: int) -> void:
	hovered_shop_button = n


func buy_item(n: int) -> void:
	var price: int = Global.weapon_list[item_catalogue[n]]["Cost"]
	if len(Global.fleet_inventory) < Global.max_inventory and Global.resources >= price:
		resources(-price)
		Global.fleet_inventory.append(item_catalogue.pop_at(n))


func sell_item(n: int) -> void:
	resources(ceil(Global.weapon_list[Global.fleet_inventory.pop_at(n)]["Cost"] / 2), 0)


func buy_ship(n: int) -> void:
	var price: int = Global.starship_base_stats[ship_catalogue[n][0]]["Cost"]
	if len(Global.fleet) < 8 and Global.resources >= price:
		resources(-price)
		Global.create_new_starship(ship_catalogue[n][0], ship_catalogue[n][1])
		ship_catalogue.remove_at(n)


func sell_ship(n: int) -> void:
	var sold_ship: Node = main.get_node("FriendlyShips").get_child(n)
	resources((ceil(Global.starship_base_stats[sold_ship.type]["Cost"]) / 2) * sold_ship.level, 0)
	sold_ship.hull = 0


func ship_action(activate: bool) -> void:
	if main.get_node("FriendlyShips").get_child(looking_at_ship_info) != null:
		main.get_node("FriendlyShips").get_child(looking_at_ship_info).active = activate


func abandon_ship() -> void:
	main.get_node("FriendlyShips").get_child(looking_at_ship_info).hull = 0


func win_encounter() -> void:
	# Tech
	resources(randi_range(8, 32))
	# Fuel
	resources(randi_range(3, 4 * len(Global.fleet) - 1), 1, true, randi_range(0, len(encounter_win_dialogue) - 1), 2)
	Global.galaxy_data[Global.current_system]["enemy presence"] = false


func lose() -> void:
	Global.playing = false
	galaxy_map_showing = false
	$GalaxyMap.hide()
	action_menu_showing = false
	$ShipActionMenu.hide()
	info_menu_showing = false
	$FleetInfoMenu.hide()
	dialogue_set_up(1, 3)


func quit_to_menu() -> void:
	Global.playing = false
	get_tree().change_scene_to_file("res://Menus/main_menu.tscn")


func restart() -> void:
	Global.new_game()
