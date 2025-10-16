extends Control


@onready var main: Node3D = get_node("/root/Space")
@onready var friendly_ships: Node3D = main.get_node("FriendlyShips")
@onready var hostile_ships: Node3D = main.get_node("HostileShips")
@export var galaxy_map_token: PackedScene
var intro_dialogue: bool = false
var fade_mode: int = -1
var galaxy_map_showing: bool = false
var dialogue_showing: bool = true
var max_option: int = 3
var ready_to_select: bool = false
var current_dialogue_selection: int = 1
var option_results: Array
var action_menu_showing: bool = false
var action_menu_up: bool = true
var info_menu_showing: bool = false
var shop_showing: bool = false
var hovered_ship: int = 0
var hovered_target: int = 0
var left_action_menu: bool = true
var selected_ship: int = 0
var targeting_mode: int = 0
var time_paused: bool = false
var info_menu_column: int = 0
var hovered_at_ship_info: int = 0
var looking_at_ship_info: int = 0
var info_showing: int = 0
var hovered_instruction: int = 0
var switch_weapon: Vector2i = Vector2i(0, 0)
var warping = false
var prev_mouse_pos: Vector2
var item_catalogue = [0, 0, 0, 0]
var ship_catalogue = [
	{"Type": 1, "Name": "ship name", "Description": "desc"},
	{"Type": 1, "Name": "ship name", "Description": "desc"},
	{"Type": 1, "Name": "ship name", "Description": "desc"}
	]
var current_shopfront: int = 0
var hovered_shop_button: int = 0
var selected_shop_side: int = 0
var enemy_ran_away: bool = false

const HOVERED_COLOUR: Color = Color(0.0, 0.749, 1.0)
const BLUE_PANEL_HOVER: Color = Color8(100, 100, 160)
const BLUE_PANEL_NORMAL: Color = Color8(0, 0, 160)
const RED_PANEL_HOVER: Color = Color8(160, 100, 100)
const RED_PANEL_NORMAL: Color = Color8(160, 0, 0)
const SHIP_CODES: Array[String] = [
	"CMND",
	"FGHT",
	"SHLD",
	"INFL",
	"REPR",
	"SCAN",
	"RLAY",
	"DRON",
	"FGHT",
	"REPR"
]
const TARGETING_OPTIONS: Array[String] = [
	"CANNOT TARGET",
	"TARGET",
	"CANNOT TARGET",
	"BOARD",
	"REPAIR",
	"MONITOR",
	"CANNOT TARGET",
	"DEPLOY"
]
const ACTIVE_TEXT: Array[String] = ["CURRENTLY INACTIVE", "CURRENTLY ACTIVE"]
const MISC_TEXT: Array[String] = [
	"FLEET INVENTORY",
	"EQUIPPED WEAPONS",
	"N/A",
	"N/A",
	"N/A",
	"N/A",
	"N/A",
	"DEPLOYED DRONES"
]
const TECH_REWARDS: Vector2i = Vector2i(4, 8)
const FUEL_REWARDS: Vector2i = Vector2i(3, 4)
const REWARD_CHANCES: int = 19
const SELL_MODIFIER: float = 0.5
const RESOURCE_COLOUR_LERP: float = 0.05
const SOLAR_FLARE_LERP: float = 0.02
const TIME_SCALE_LERP: float = 0.15
const CURSOR_LERP: float = 0.2
const ACTION_MENU_LERP: float = 0.15
const ACTION_MENU_UP_POS: float = 788.0
const ACTION_MENU_DOWN_POS: float = 1000.0
const FPS_LABEL: String = "FPS: "
const TECH_LABEL: String = "TECH: "
const FUEL_LABEL: String = "FUEL: "
const CHARGE_WAITING_TEXT: String = "WAITING"
const WARP_CHARGING_TEXT: String = "WARP CHARGING"
const WARP_CHARGED_TEXT: String = "WARP CHARGED"
const MAX_WARP_CHARGE: float = 100.0
const MAP_CURSOR_SPEED: float = 400.0
const CURSOR_SPEED: float = 250.0
const WARP_STAGE_A_TIME: float = 0.5
const WARP_STAGE_B_TIME: float = 3.0
const WARP_STAGE_C_TIME: float = 4.0
const MAP_TOKENS_RANGE: Vector2 = Vector2(-2040.0, 45.0)
const MAP_CURSOR_MIN: Vector2 = Vector2(385.0, 256.0)
const MAP_CURSOR_MAX: Vector2 = Vector2(1535.0, 824.0)
const ACTION_MENU_VERTICAL: int = 4
const AGILITY_FACTOR: float = 100.0
const SHIP_LIST_SEPARATOR: String = ": "
const HULL_STRENGTH_TEXT: String = "HULL STRENGTH: "
const CURRENT_HULL_TEXT: String = "CURRENT HULL: "
const AGILITY_TEXT: String = "AGILITY: "
const CURRENT_LEVEL_TEXT: String = "CURRENT LEVEL: "
const UPGRADE_COST_TEXT: String = "UPGRADE COST: "
const INVENTORY_CAPACITY_TEXT: String = "INVENTORY CAPACITY: "
const ITEM_TEXT: String = " ITEM: "
const TYPE_TEXT: String = " TYPE: "
const VALUE_TEXT: String = " VALUE: "
const TECH_SUFFIX: String = " TECH"
const WEAPON_SLOTS_TEXT: String = "WEAPON SLOTS: "
const DAMAGE_TEXT: String = " DAMAGE: "
const RELOAD_TEXT: String = " RELOAD: "
const DRONE_SLOTS_TEXT: String = "DRONE SLOTS: "
const DRONE_TEXT: String = " DRONE: "
const HULL_TEXT: String = " HULL: "
const MAX_INSTRUCTION: int = 2
const NAME_TEXT: String = " NAME: "
const HULL_SUFFIX: String = " HULL"
const SECONDS_SUFFIX: String = " SECONDS"
const SELL_VALUE_TEXT: String = " SELL VALUE: "
const LEVEL_TEXT: String = " LEVEL: "
const MAP_AUTO_SCROLL_THRESHOLD: float = 900.0
const MAP_SCROLL_OFFSET: float = 600.0
const MAP_DEFAULT_SCROLL: float = 45.0
const LOSE_DIALOGUE_ID: int = 3

enum ResourceType {
	TECH,
	FUEL
}

enum ActionMenu {
	TOP_LEFT,
	TOP_RIGHT = 3,
	BOTTOM_LEFT,
	BOTTOM_RIGHT = 7
}

enum InfoColumn {
	SHIPS,
	INFO_TABS,
	INFO_VIEW
}

enum InfoTabs {
	GENERAL,
	LEVELING,
	INSTRUCTIONS,
	MISC
}

enum DialogueTypes {
	WARP_IN,
	RESPONSE,
	ENCOUNTER_WIN,
	INTRO,
	TUTORIAL,
	ITEM_WIN,
	ENEMY_RUNNING,
	ENEMY_RAN_AWAY
}

enum Shopfronts {
	ITEMS,
	SHIPS
}

enum ShopSides {
	BUYING,
	SELLING
}

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
	[["Noted.", ["dialogue_set_up", DialogueTypes.TUTORIAL, 6]]]
	],
	[[2, "tutorial", "enemy presence"],
	"Watch out! There are pirates in this system, and they'll engage you immediately. Don't panic, however. You are fortunately a quick-minded commander, and can temporarily stop time by pressing the pause time button.",
	[["Noted.", ["dialogue_set_up", DialogueTypes.TUTORIAL, 6]]]
	],
	[[3, "tutorial", "enemy presence"],
	"Watch out! There are pirates in this system, and they'll engage you immediately. Don't panic, however. You are fortunately a quick-minded commander, and can temporarily stop time by pressing the pause time button.",
	[["Noted.", ["dialogue_set_up", DialogueTypes.TUTORIAL, 6]]]
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
	"Well done for completing this short introductory course to FATAL FLEET.\nDon't forget - this is a difficult game. I hope you enjoy your journey through the galaxy.\nYou may redo this tutorial anytime from the main menu.",
	[["OK.", ["close", false, true]]]
	],
	[[2, "tutorial", "destination"],
	"Well done for completing this short introductory course to FATAL FLEET.\nDon't forget - this is a difficult game. I hope you enjoy your journey through the galaxy.\nYou may redo this tutorial anytime from the main menu.",
	[["OK.", ["close", false, true]]]
	],
	[[3, "tutorial", "destination"],
	"Well done for completing this short introductory course to FATAL FLEET.\nDon't forget - this is a difficult game. I hope you enjoy your journey through the galaxy.\nYou may redo this tutorial anytime from the main menu.",
	[["OK.", ["close", false, true]]]
	],
	[[1, "destination"],
	"You have finally arrived at your ultimate destination. Leading your fleet to the nearby Alliance outpost, you hail the personnel who await your arrival. Despite the challenges you and your crew have faced, you were successful in your mission.\nThank you for playing FATAL FLEET.",
	[["Complete the delivery.", ["close", false, true]]]
	],
	[[2, "destination"],
	"You have finally arrived at your ultimate destination. Leading your fleet to the nearby Alliance outpost, you hail the personnel who await your arrival. Despite the challenges you and your crew have faced, you were successful in your mission.\nThank you for playing FATAL FLEET.",
	[["Complete the delivery.", ["close", false, true]]]
	],
	[[3, "destination"],
	"You have finally arrived at your ultimate destination. Leading your fleet to the nearby Alliance outpost, you hail the personnel who await your arrival. Despite the challenges you and your crew have faced, you were successful in your mission.\nThank you for playing FATAL FLEET.",
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
	[["Scrap what's left of the freighter hulls.", ["resources", randi_range(10, 25), 0, true, 0]], ["Leave it alone for now.", ["close", false]]]
	],
	[[1],
	"As you warp into the system, your fleet finds itself surrounded by a number of large wreckages. It looks like pirates must have found good prey in a convoy of freighters.",
	[["Scrap what's left of the freighter hulls.", ["dialogue_set_up", DialogueTypes.RESPONSE, 1]], ["Leave it alone for now.", ["close", false]]]
	],
	[[1],
	"As you warp into the system, your fleet finds itself surrounded by a number of large wreckages. It looks like pirates must have found good prey in a convoy of freighters.",
	[["Scrap what's left of the freighter hulls.", ["resources", randi_range(25, 40), 0, true, 2]], ["Leave it alone for now.", ["close", false]]]
	],
	[[1],
	"As you warp into the system, your fleet finds itself surrounded by a number of large wreckages. It looks like pirates must have found good prey in a convoy of freighters.",
	[["Scrap what's left of the freighter hulls.", ["resources", randi_range(3, 16), 1, true, 4]], ["Leave it alone for now.", ["close", false]]]
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
	"Your fleet exits warp, and you realise that you're uncomfortably close to a star. Suddenly, your systems warn you of a nearby threat. A pirate fleet either unaware or uncaring of the danger streaks into view.",
	[["Hope that the star doesn't pose too much of an issue and get ready for combat.", ["close", true]]]
	],
	[[3, "shop presence", "star proximity"],
	"As your fleet exits warp, you're set on edge as you're hailed by a lone starship, close to the nearby star.\n\"Ho, there! I'm a travelling merchant - I can shield us from the star, if you're willing to take a gander at what I have.\"\nYou decide it could be worth a look.",
	[["Return friendly communications.", ["close", false]]]
	],
]

var response_dialogue: Array[Array] = [ # Main text, [option, result]
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

var enemy_running_dialogue: Array[Array] = [ # Main text, [option, result]
	["In the middle of combat, you notice the enemy fleet is beginning to charge its warp drives, in an attempt to get away!",
	[["Continue combat.", ["close", true]]]
	],
]

var enemy_ran_away_dialogues: Array[Array] = [ # Main text, [option, result]
	["Unfortunately - or fortunately - depending on how you look at it, the remaining enemy ships managed to get away. You pick through the remains of the scrap you did manage to break down and take what's useful.\nAt least you won't have to deal with them again.",
	[["Move on with the journey.", ["close", false]]]
	],
]

var encounter_win_dialogues: Array[Array] = [
	["As soon as the final ship in the enemy fleet is torn apart, you strip down each worn ship carcass for materials.",
	[["Continue the journey.", ["close", false]]]
	],
	["With the enemy fleet defeated, you order your crews to quickly search the wreckages for anything useful.",
	[["Collect scrap and continue the journey.", ["close", false]]]
	],
	["You barely manage to hear muffled screams through the static of the final enemy ship's transmitters. As the sound fades away, you gather resources from the fresh debris field.",
	[["Reap your reward and move on.", ["close", false]]]
	],
	["You have defeated the enemy fleet, and live to see another day.",
	[["Continue the journey.", ["close", false]]]
	],
	["With its hull gradually failing, the final enemy ship attempts to start firing up its warp drives - but it is too late.\nYour crews search what's left of the enemy fleet, finding some useful resources.",
	[["Stash your findings and continue the journey.", ["close", false]]]
	],
]

var item_win_dialogues: Array[Array] = [
	["As soon as the final ship in the enemy fleet is torn apart, you strip down each worn ship carcass for materials. Among the debris, your crews manage to find an undamaged piece of equipment!\nYou got the ",
	[["Continue the journey.", ["close", false]]]
	],
	["Searching the broken parts of the destroyed ships, your fleet is able to stock up on tech and fuel, but you also manage to find something of more significant value: a ",
	[["Continue the journey.", ["close", false]]]
	],
]

var intro_dialogues: Array[Array] = [
	["You, as an Alliance fleet commander, have been tasked with a crucial mission: deliver a package of goods and weapons to an isolated Alliance navy, who are currently fighting against the rebel uprising. The region of space ahead is outside of policed Alliance territory and is rife with pirates and other threats. In the rush to respond to the sudden rebel presence, you were only able to mobilise a small squadron of starships.\nMake the delivery, and save millions of lives.\nThe rest is up to you.",
	[["Let's go.", ["close", false]]]
	],
	["Welcome, commander, to FATAL FLEET! You have been given authority of a small fleet of ships, and are expected to be able to adequately lead those ships through the cosmos.\nIn this tutorial, you will learn the ropes of fleet command, including the basics of combat.",
	[["Continue", ["dialogue_set_up", DialogueTypes.TUTORIAL, 0]]]
	],
]

var tutorial_dialogues: Array[Array] = [
	["First and foremost, the right side of your interface shows your controls and their related keyboard shortcuts. You can hide or show this at will.\nAt the top of your interface, you can see how much \"tech\" (galactic currency) you currently have, as well as how much fuel you have ready to use. Each ship in your fleet requires one fuel canister to jump between star systems. The bar to the right of that displays your fleet's current warp charge progress. You will not be able to travel to another system until your warp drives have finished charging.\nYou can hide the entire interface at any time by holding \"~\".",
	[["OK.", ["dialogue_set_up", DialogueTypes.TUTORIAL, 1]], ["Back", ["dialogue_set_up", DialogueTypes.INTRO, 1]]]
	],
	["A crucial part of your toolset is the Fleet Information Menu. This panel can be accessed by pressing the Info Menu button and contains useful data about the starships in your fleet. You can also give instructions to them, upgrade them or possibly change up their equipment.",
	[["OK.", ["dialogue_set_up", DialogueTypes.TUTORIAL, 2]], ["Back", ["dialogue_set_up", DialogueTypes.TUTORIAL, 0]]]
	],
	["Speaking of starships, there are eight different types you should know about.\nCMND: Command Ship - Your fleet's flagship, within which you are seated. It is imperative that you protect this ship.\nFGHT: Fighter - Engages with and destroys threats as instructed by you. You can change which weapons it uses in the Fleet Info Menu.\nSHLD: Shield Ship - Protects your fleet from incoming projectiles. Can be bypassed by some projectiles and will need to recharge upon successfully blocking one.",
	[["Continue", ["dialogue_set_up", DialogueTypes.TUTORIAL, 3]], ["Back", ["dialogue_set_up", DialogueTypes.TUTORIAL, 1]]]
	],
	["INFL: Infiltration Ship - Teleports troops onto enemy starships to temporarily disable them.\nREPR: Repair Ship - Gradually repairs your starships' hulls in and out of combat.\nSCAN: Scanner Ship - Scans enemy starships, revealing information about them and searching for weak spots.",
	[["Continue", ["dialogue_set_up", DialogueTypes.TUTORIAL, 4]], ["Back", ["dialogue_set_up", DialogueTypes.TUTORIAL, 2]]]
	],
	["RLAY: Relay Ship - Boosts your warp drive charge rate and increases the distance you can travel in one jump.\nDRON: Drone Command Ship - Deploys drones to autonomously aid you in battle. Can operate fighter or repair drones, depending on its upgrade level.",
	[["OK.", ["dialogue_set_up", DialogueTypes.TUTORIAL, 5]], ["Back", ["dialogue_set_up", DialogueTypes.TUTORIAL, 3]]]
	],
	["That's all for now. Have a play around with the menus and, when ready, open the Galaxy Map with the Galaxy Map button to warp to the next system.",
	[["OK.", ["close", false]], ["Back", ["dialogue_set_up", DialogueTypes.TUTORIAL, 4]]]
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
	# Wait for the game to be established
	if Global.initialising:
		intro_dialogue = true
		await main.setup_complete
	# Generate visual galaxy map
	for token in Global.galaxy_data:
		var new_token: Area2D = galaxy_map_token.instantiate()
		new_token.id = token["id"]
		new_token.position = token["position"]
		$GalaxyMap/Tokens.add_child(new_token)


func _process(delta: float) -> void:
	# Debug stuff
	if Input.is_action_pressed("debug"):
		$FPS.show()
	else:
		$FPS.hide()
	$FPS.text = FPS_LABEL + str(1 / delta)
	
	# Update fuel and resource UI elements
	%ResourcesLabel.text = TECH_LABEL + str(Global.resources)
	%ResourcesLabel.add_theme_color_override(
			"font_color",
			lerp(
					%ResourcesLabel.get_theme_color("font_color"),
					Color.WHITE,
					RESOURCE_COLOUR_LERP
			)
	)
	%FuelLabel.text = FUEL_LABEL + str(Global.fuel)
	%FuelLabel.add_theme_color_override(
			"font_color",
			lerp(
					%FuelLabel.get_theme_color("font_color"),
					Color.WHITE,
					RESOURCE_COLOUR_LERP
			)
	)
	
	%ChargeProgress.value = main.warp_charge
	
	# Screen fade stuff
	$ScreenFade.color.a += fade_mode * delta
	$ScreenFade.color.a = clamp($ScreenFade.color.a, 0, 1)
	
	$SolarFlareFlash.self_modulate.a = lerp($SolarFlareFlash.self_modulate.a, 0.0, SOLAR_FLARE_LERP)
	
	# What a terrible day to have eyes
	var shop_in_system: bool = "shop presence" in main.system_properties
	if (
			(Input.is_action_just_pressed("action menu")
			and not Global.joystick_control)
			or (Global.joystick_control
					and (Input.is_action_just_pressed("2")
							or Input.is_action_just_pressed("B"))
			)
	):
		_action_menu()
	
	if (
			(Input.is_action_just_pressed("info menu")
					and not Global.joystick_control)
			or (Global.joystick_control
					and (Input.is_action_just_pressed("3")
							or Input.is_action_just_pressed("C"))
			)
	):
		_info_menu()
	
	if (
			(Input.is_action_just_pressed("galaxy map")
					and not Global.joystick_control)
			or (Global.joystick_control
					and (Input.is_action_just_pressed("4")
							or Input.is_action_just_pressed("D"))
			)
	):
		_galaxy_map()
	
	if (
			(Input.is_action_just_pressed("time pause")
					and not Global.joystick_control)
			or (Global.joystick_control
					and (Input.is_action_just_pressed("5")
							or Input.is_action_just_pressed("E"))
					and not shop_in_system
			)
	):
		_time_pause()
	
	if (
			(Input.is_action_just_pressed("shop")
					and not Global.joystick_control)
			or (Global.joystick_control
					and (Input.is_action_just_pressed("5")
							or Input.is_action_just_pressed("E"))
			)
	):
		_shop()
	
	if (
			(
					(Input.is_action_just_pressed("pause")
							and not Global.joystick_control)
					or (Global.joystick_control
							and (Input.is_action_just_pressed("6")
									or Input.is_action_just_pressed("F"))
					)
			)
	):
		_pause()
	
	if (
			(Input.is_action_just_pressed("hide controls")
					and not Global.joystick_control)
			or (Global.joystick_control
					and (Input.is_action_just_pressed("1")
							or Input.is_action_just_pressed("A"))
			)
	):
		_hide_controls()
	
	if Global.controls_showing:
		$ControlTips/VBoxContainer/Main.show()
	else:
		$ControlTips/VBoxContainer/Main.hide()
	
	# Check if the dialogue is showing:
	if dialogue_showing:
		# Move selection up/down
		if Global.joystick_control:
			if Input.is_action_just_pressed("up1") or Input.is_action_just_pressed("up2"):
				current_dialogue_selection -= 1
				$HoverSFX.play()
			if Input.is_action_just_pressed("down1") or Input.is_action_just_pressed("down2"):
				current_dialogue_selection += 1
				$HoverSFX.play()
			current_dialogue_selection = clampi(current_dialogue_selection, 1, max_option)
			# Select
			if (
					(Input.is_action_just_pressed("1")
							or Input.is_action_just_pressed("A"))
					and ready_to_select
			):
				select_dialogue(current_dialogue_selection)
			# Appropriately colour the selected option
			for option in max_option:
				if option + 1 == current_dialogue_selection:
					%Options.get_node("Option" + str(option + 1)).add_theme_color_override(
							"font_color",
							HOVERED_COLOUR
					)
				else:
					%Options.get_node("Option" + str(option + 1)).add_theme_color_override(
							"font_color",
							Color.WHITE
					)
		else:
			# Check for numerical inputs
			for option in max_option:
				if Input.is_action_just_pressed(str(option + 1)) and ready_to_select:
					%Options.get_node("Option" + str(option + 1)).emit_signal("pressed")
		# Warp charge text
		%ChargeProgress/Label.text = CHARGE_WAITING_TEXT
	else:
		if main.warp_charge < MAX_WARP_CHARGE:
			%ChargeProgress/Label.text = WARP_CHARGING_TEXT
		else:
			%ChargeProgress/Label.text = WARP_CHARGED_TEXT
	
	# Change which keybind is displayed by the control tip panels
	for tip in $ControlTips/VBoxContainer/Main.get_children():
		tip.get_child(0).text = control_tip_texts[tip.name][int(Global.joystick_control)]
	if Global.controls_showing:
		$ControlTips/VBoxContainer/HideControlTips/Button.text \
				= control_tip_texts["HideControlTips"][int(Global.joystick_control)]
	else:
		$ControlTips/VBoxContainer/HideControlTips/Button.text \
				= control_tip_texts["ShowControlTips"][int(Global.joystick_control)]
	
	# Change time scale
	if time_paused:
		Engine.time_scale = lerp(Engine.time_scale, 0.0, TIME_SCALE_LERP)
		$TimeIndicator.show()
	else:
		Engine.time_scale = lerp(Engine.time_scale, 1.0, TIME_SCALE_LERP)
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
			$GalaxyMap/Tokens.position.x -= MAP_CURSOR_SPEED * delta * Global.joystick_sens
		if Input.is_action_pressed("left2"):
			$GalaxyMap/Tokens.position.x += MAP_CURSOR_SPEED * delta * Global.joystick_sens
		%Cursor.position += Vector2(
				Input.get_axis("left1", "right1"),
				Input.get_axis("up1", "down1")
		).normalized() * CURSOR_SPEED * Global.joystick_sens * delta
		# Move the map cursor if the mouse is detected to be moving
		if get_global_mouse_position() != prev_mouse_pos and not Global.joystick_control:
			%Cursor.global_position = get_global_mouse_position()
		# Cursor snapping
		if (
				Input.get_axis("left1", "right1") == 0
				and Input.get_axis("up1", "down1") == 0
				and len(%Cursor.get_overlapping_areas()) > 0
		):
			var in_warp_range: bool = false
			var closest_token: Dictionary = {"Number": 0, "Distance": 400.0, "id": 0}
			var n: int = 0
			for token in %Cursor.get_overlapping_areas():
				var x: Dictionary = {
					"Number": n,
					"Distance": %Cursor.position.distance_squared_to(token.position),
					"id": token.id
					}
				if x["Distance"] < closest_token["Distance"]:
					closest_token = x
					if token.position.distance_to(Global.system_position) <= Global.jump_distance:
						in_warp_range = true
				n += 1
			%Cursor.position = lerp(
					%Cursor.position,
					%Cursor.get_overlapping_areas()[closest_token["Number"]].position,
					CURSOR_LERP
			)
			# Warping input
			# This is awful
			if (
					(
							(
									(Input.is_action_just_pressed("1")
											or Input.is_action_just_pressed("A"))
									and Global.joystick_control
							)
							or (Input.is_action_just_pressed("warp")
									and not Global.joystick_control)
					)
					and in_warp_range
					and closest_token["id"] != Global.current_system
					and Global.fuel >= len(Global.fleet)
			):
				$PressSFX.play()
				# Save data
				if "shop presence" in main.system_properties:
					Global.galaxy_data[Global.current_system]["item shop"] = item_catalogue
					Global.galaxy_data[Global.current_system]["ship shop"] = ship_catalogue
				if "enemy presence" in main.system_properties:
					Global.galaxy_data[Global.current_system]["enemies"] = []
					for enemy in hostile_ships.get_children():
						if enemy.type == Global.StarshipTypes.DRONE_COMMAND:
							Global.galaxy_data[Global.current_system]["enemies"].append(
									[enemy.type, enemy.level, enemy.drones]
							)
						else:
							Global.galaxy_data[Global.current_system]["enemies"].append(
									[enemy.type, enemy.level, enemy.weapons]
							)
					Global.galaxy_data[Global.current_system]["enemy count"] = main.enemy_ship_count
				# Warping process
				Engine.time_scale = 1.0
				warping = true
				time_paused = false
				galaxy_map_showing = false
				Global.in_combat = false
				resources(-len(Global.fleet), ResourceType.FUEL)
				Global.new_system(closest_token["id"])
				# Warp sequence
				await get_tree().create_timer(WARP_STAGE_A_TIME).timeout
				main.commence_warp()
				await get_tree().create_timer(WARP_STAGE_B_TIME).timeout
				fade_mode = 1
				await get_tree().create_timer(WARP_STAGE_C_TIME).timeout
				Global.game_music_progress = main.get_node("MusicExplore").get_playback_position()
				main.get_tree().reload_current_scene()
		# Clamping of galaxy map node positions
		$GalaxyMap/Tokens.position.x = clampf(
				$GalaxyMap/Tokens.position.x,
				MAP_TOKENS_RANGE.x,
				MAP_TOKENS_RANGE.y
		)
		%Cursor.global_position.x = clampf(
				%Cursor.global_position.x,
				MAP_CURSOR_MIN.x,
				MAP_CURSOR_MAX.x
		)
		%Cursor.global_position.y = clampf(
				%Cursor.global_position.y,
				MAP_CURSOR_MIN.y,
				MAP_CURSOR_MAX.y
		)
	else:
		# Not showing
		$GalaxyMap.hide()
		$GalaxyMapTitle.hide()
		$GalaxyMapControls.hide()
	
	# Ship action menu behaviour
	if action_menu_showing:
		$ShipActionMenu.show()
		if Global.joystick_control:
			action_menu_up = true
			$ShipActionMenu.position.y = ACTION_MENU_UP_POS
			if Global.dual_joysticks:
				if Input.is_action_just_pressed("left1"):
					selected_ship -= 1
					$HoverSFX.play()
				if Input.is_action_just_pressed("right1"):
					selected_ship += 1
					$HoverSFX.play()
				if Input.is_action_just_pressed("down1"):
					selected_ship += ACTION_MENU_VERTICAL
					$HoverSFX.play()
				if Input.is_action_just_pressed("up1"):
					selected_ship -= ACTION_MENU_VERTICAL
					$HoverSFX.play()
				if Input.is_action_just_pressed("left2"):
					hovered_target -= 1
					$HoverSFX.play()
				if Input.is_action_just_pressed("right2"):
					hovered_target += 1
					$HoverSFX.play()
				if Input.is_action_just_pressed("down2"):
					hovered_target += ACTION_MENU_VERTICAL
					$HoverSFX.play()
				if Input.is_action_just_pressed("up2"):
					hovered_target -= ACTION_MENU_VERTICAL
					$HoverSFX.play()
				selected_ship = clampi(selected_ship, 0, friendly_ships.get_child_count() - 1)
				select_ship()
			# Output depends on which side of the action menu the player is hovering
			elif left_action_menu:
				if Input.is_action_just_pressed("left1"):
					if (
							hovered_ship == ActionMenu.TOP_LEFT
							and %ActionTargetShips/GridContainer/Ship3.visible
					):
						left_action_menu = false
						hovered_target = ActionMenu.TOP_RIGHT
					elif (
							hovered_ship == ActionMenu.BOTTOM_LEFT
							and %ActionTargetShips/GridContainer/Ship7.visible
					):
						left_action_menu = false
						hovered_target = ActionMenu.BOTTOM_RIGHT
					else:
						hovered_ship -= 1
					$HoverSFX.play()
				if Input.is_action_just_pressed("right1"):
					if (
							hovered_ship == ActionMenu.TOP_RIGHT
							and %ActionTargetShips/GridContainer/Ship0.visible
					):
						left_action_menu = false
						hovered_target = ActionMenu.TOP_LEFT
					elif (
							hovered_ship == ActionMenu.BOTTOM_RIGHT
							and %ActionTargetShips/GridContainer/Ship4.visible
					):
						left_action_menu = false
						hovered_target = ActionMenu.BOTTOM_LEFT
					else:
						hovered_ship += 1
					$HoverSFX.play()
				if Input.is_action_just_pressed("down1"):
					hovered_ship += ACTION_MENU_VERTICAL
					$HoverSFX.play()
				if Input.is_action_just_pressed("up1"):
					hovered_ship -= ACTION_MENU_VERTICAL
					$HoverSFX.play()
			elif not left_action_menu:
				if Input.is_action_just_pressed("left1"):
					if (
							hovered_target == ActionMenu.TOP_LEFT
							and %ActionFriendlyShips/GridContainer/Ship3.visible
					):
						left_action_menu = true
						hovered_ship = ActionMenu.TOP_RIGHT
					elif (
							hovered_target == ActionMenu.BOTTOM_LEFT
							and %ActionFriendlyShips/GridContainer/Ship7.visible
					):
						left_action_menu = true
						hovered_ship = ActionMenu.BOTTOM_RIGHT
					else:
						hovered_target -= 1
					$HoverSFX.play()
				if Input.is_action_just_pressed("right1"):
					if hovered_target == ActionMenu.TOP_RIGHT:
						left_action_menu = true
						hovered_ship = ActionMenu.TOP_LEFT
					elif (
							hovered_target == ActionMenu.BOTTOM_RIGHT
							and %ActionFriendlyShips/GridContainer/Ship4.visible
					):
						left_action_menu = true
						hovered_ship = ActionMenu.BOTTOM_LEFT
					else:
						hovered_target += 1
					$HoverSFX.play()
				if Input.is_action_just_pressed("down1"):
					hovered_target += ACTION_MENU_VERTICAL
					$HoverSFX.play()
				if Input.is_action_just_pressed("up1"):
					hovered_target -= ACTION_MENU_VERTICAL
					$HoverSFX.play()
			hovered_ship = clamp(hovered_ship, 0, friendly_ships.get_child_count() - 1)
		else:
			# Manage action menu up or down
			if action_menu_up:
				$ShipActionMenu.position.y = lerp(
						$ShipActionMenu.position.y,
						ACTION_MENU_UP_POS,
						ACTION_MENU_LERP
				)
				if get_global_mouse_position().y < ACTION_MENU_UP_POS:
					action_menu_up = false
			else:
				$ShipActionMenu.position.y = lerp(
						$ShipActionMenu.position.y,
						ACTION_MENU_DOWN_POS,
						ACTION_MENU_LERP
				)
				if get_global_mouse_position().y > ACTION_MENU_DOWN_POS:
					action_menu_up = true
		# Hide all children so they can be selectively shown
		for child in %ActionTargetShips/GridContainer.get_children():
			child.hide()
		for child in %ActionFriendlyShips/GridContainer.get_children():
			child.hide()
		# Display available targets
		var index: int = 0
		# Does this ship target the enemy?
		if targeting_mode in Global.ENEMY_TARGETERS:
			var hostiles_count: int = hostile_ships.get_child_count()
			if hostiles_count > 0:
				%ActionTargetShips/NoTargets.hide()
				hovered_target = clamp(hovered_target, 0, hostiles_count - 1)
				for ship in hostile_ships.get_children():
					var box: PanelContainer = %ActionTargetShips/GridContainer.get_child(index)
					var stylebox: Resource = box.get_theme_stylebox("panel")
					box.get_node("Code").text = SHIP_CODES[ship.type]
					if (
							index == hovered_target
							and (Global.joystick_control
									and (Global.dual_joysticks
											or (not Global.dual_joysticks
													and not left_action_menu)
									)
									or not Global.joystick_control
							)
					):
						stylebox.border_color = BLUE_PANEL_HOVER
					else:
						stylebox.border_color = BLUE_PANEL_NORMAL
					if selected_ship < friendly_ships.get_child_count():
						var friendly: Node3D = friendly_ships.get_child(selected_ship)
						if friendly != null:
							if friendly.target != null:
								if index == friendly.target.get_index():
									stylebox.draw_center = true
								else:
									stylebox.draw_center = false
						box.show()
						index += 1
			else:
				%ActionTargetShips/NoTargets.show()
		# Does this ship target friendlies?
		elif targeting_mode == Global.StarshipTypes.REPAIR:
			%ActionTargetShips/NoTargets.hide()
			for ship in friendly_ships.get_children():
				var box: PanelContainer = %ActionTargetShips/GridContainer.get_child(index)
				var stylebox: Resource = box.get_theme_stylebox("panel")
				box.get_node("Code").text = SHIP_CODES[ship.type]
				if (
						index == hovered_target
						and (Global.joystick_control
								and (Global.dual_joysticks
										or (not Global.dual_joysticks
												and not left_action_menu)
								)
								or not Global.joystick_control
						)
				):
					stylebox.border_color = BLUE_PANEL_HOVER
				else:
					stylebox.border_color = BLUE_PANEL_NORMAL
				var friendly: Node3D = friendly_ships.get_child(selected_ship)
				if friendly != null:
					if friendly.target != null:
						if index == friendly.target.get_index():
							stylebox.draw_center = true
						else:
							stylebox.draw_center = false
				box.show()
				index += 1
		# Ship doesn't target anything
		else:
			%ActionTargetShips/NoTargets.hide()
		# Display player's fleet
		index = 0
		for ship in friendly_ships.get_children():
			var box: PanelContainer = %ActionFriendlyShips/GridContainer.get_child(index)
			var stylebox: Resource = box.get_theme_stylebox("panel")
			box.get_node("Code").text = SHIP_CODES[ship.type]
			if (
					index == hovered_ship
					and (
							(Global.joystick_control
									and not Global.dual_joysticks
									and left_action_menu
							)
							or not Global.joystick_control
					)
			):
				stylebox.border_color = RED_PANEL_HOVER
			else:
				stylebox.border_color = RED_PANEL_NORMAL
			if index == selected_ship:
				stylebox.draw_center = true
			else:
				stylebox.draw_center = false
			box.show()
			index += 1
		if (
				Global.joystick_control
				and (Input.is_action_just_pressed("1")
						or Input.is_action_just_pressed("A")
				)
		):
			if Global.dual_joysticks:
				friendly_ships.get_child(selected_ship).new_target(hovered_target)
				$PressSFX.play()
			elif left_action_menu:
				selected_ship = hovered_ship
				select_ship()
				$PressSFX.play()
			else:
				friendly_ships.get_child(selected_ship).new_target(hovered_target)
				$PressSFX.play()
	else:
		$ShipActionMenu.hide()
	
	# Fleet information menu behaviour
	if info_menu_showing:
		$FleetInfoMenu.show()
		# Leftmost menu displaying all ships in the player's fleet
		var index: int = 0
		var fleet_size: int = friendly_ships.get_child_count()
		for button in %ShipSelection.get_children():
			if index < fleet_size:
				var ship: Node3D = friendly_ships.get_child(index)
				button.show()
				button.get_child(0).text \
						= SHIP_CODES[ship.type] + SHIP_LIST_SEPARATOR + ship.ship_name.to_upper()
				var stylebox: Resource = button.get_theme_stylebox("panel")
				if (
						index == hovered_at_ship_info
						and (not Global.joystick_control
								or (Global.joystick_control
										and info_menu_column == 0)
						)
				):
					stylebox.border_color = RED_PANEL_HOVER
				else:
					stylebox.border_color = RED_PANEL_NORMAL
				if index == looking_at_ship_info:
					stylebox.draw_center = true
					# General stats labels
					%Information/General/HullStrength/Label.text \
							= HULL_STRENGTH_TEXT + str(ship.hull_strength)
					%Information/General/Hull/Label.text = CURRENT_HULL_TEXT + str(ship.hull)
					%Information/General/Agility/Label.text \
							= AGILITY_TEXT + str(ship.agility * AGILITY_FACTOR) + "%"
					%Information/General/Status/Label.text \
							= Global.STATUS_MESSAGES[int(ship.attacked)]
					# Leveling information labels
					%Information/Leveling/CurrentLevel/Label.text \
							= CURRENT_LEVEL_TEXT + str(ship.level)
					if ship.level < ship.MAX_LEVEL and not Global.in_combat:
						%Information/Leveling/Cost/Label.text = UPGRADE_COST_TEXT + str(
								Global.upgrade_costs[ship.type][ship.level - 1]
						)
						%Information/Leveling/Specification0/Label.text \
								= Global.upgrade_specifications[ship.type][ship.level - 1][0]
						%Information/Leveling/Specification1/Label.text \
								= Global.upgrade_specifications[ship.type][ship.level - 1][1]
						%Information/Leveling/Specification2/Label.text \
								= Global.upgrade_specifications[ship.type][ship.level - 1][2]
						get_tree().call_group("leveling panels", "show")
					else:
						get_tree().call_group("leveling panels", "hide")
					# Instructions labels
					%Information/Instructions/Active/Label.text = ACTIVE_TEXT[int(ship.active)]
					%Information/Instructions/TakeAction/Button.text \
							= Global.ship_actions[ship.type][0]
					%Information/Instructions/CeaseAction/Button.text \
							= Global.ship_actions[ship.type][1]
					%Information/Misc/RelatedStat/Label.text = MISC_TEXT[ship.type]
					# Miscellanious information labels
					for child in %MiscMenu.get_children():
						child.hide()
					# Inventory display
					if ship.type == Global.StarshipTypes.COMMAND_SHIP:
						%Information/Misc/RelatedStat2.show()
						%MiscMenu/CommandShip.show()
						%Information/Misc/RelatedStat2/Label.text \
								= INVENTORY_CAPACITY_TEXT + str(Global.max_inventory)
						for child in %MiscMenu/CommandShip.get_children():
							child.hide()
						var child_index: int = 0
						for item in Global.fleet_inventory:
							var this_child: Node = %MiscMenu/CommandShip.get_child(child_index)
							this_child.show()
							this_child.get_node("Labels/Name").text \
									= ITEM_TEXT + Global.weapon_list[item]["Name"]
							this_child.get_node("Labels/Type").text \
									= TYPE_TEXT + Global.weapon_types[
											Global.weapon_list[item]["Type"]
									]
							this_child.get_node("Labels/Value").text \
									= VALUE_TEXT + str(
											Global.weapon_list[item]["Cost"]
									) + TECH_SUFFIX
							child_index += 1
					# Weapon selection
					elif ship.type == Global.StarshipTypes.FIGHTER:
						%Information/Misc/RelatedStat2.show()
						%MiscMenu/Fighter.show()
						%Information/Misc/RelatedStat2/Label.text = WEAPON_SLOTS_TEXT + str(ship.level)
						for child in %MiscMenu/Fighter.get_children():
							child.hide()
						var child_index: int = 0
						var root: VBoxContainer = %MiscMenu/Fighter
						for weapon in ship.weapons:
							root.get_child(child_index).show()
							root.get_child(child_index + 1).show()
							root.get_child(child_index).get_node("HBoxContainer/Label").text \
									= Global.weapon_list[weapon]["Name"]
							root.get_child(child_index + 1).get_node("Labels/Type").text \
									= TYPE_TEXT + str(
											Global.weapon_types[Global.weapon_list[weapon]["Type"]]
									)
							root.get_child(child_index + 1).get_node("Labels/Damage").text \
									= DAMAGE_TEXT + str(Global.weapon_list[weapon]["Damage"])
							root.get_child(child_index + 1).get_node("Labels/Reload").text \
									= RELOAD_TEXT + str(Global.weapon_list[weapon]["Reload time"])
							# Reshown as it may have been hidden by the drone view
							root.get_child(child_index + 1).get_node("Labels/Reload").show()
							child_index += 2
					# Drones selection
					elif ship.type == Global.StarshipTypes.DRONE_COMMAND:
						%Information/Misc/RelatedStat2.show()
						%MiscMenu/Fighter.show()
						%Information/Misc/RelatedStat2/Label.text \
								= DRONE_SLOTS_TEXT + str(ship.level)
						for child in %MiscMenu/Fighter.get_children():
							child.hide()
						var child_index: int = 0
						var root: VBoxContainer = %MiscMenu/Fighter
						for drone in ship.drones:
							root.get_child(child_index).show()
							root.get_child(child_index + 1).show()
							@warning_ignore("integer_division") # Always divisible by 2
							root.get_child(child_index).get_node("HBoxContainer/Label").text \
									= DRONE_TEXT + str((child_index / 2) + 1)
							root.get_child(child_index + 1).get_node("Labels/Type").text \
									= TYPE_TEXT + SHIP_CODES[Global.weapon_list[drone]["Ship type"]]
							root.get_child(child_index + 1).get_node("Labels/Damage").text \
									= HULL_TEXT + str(Global.starship_base_stats[
											Global.weapon_list[drone]["Ship type"]
									]["Hull Strength"])
							root.get_child(child_index + 1).get_node("Labels/Reload").hide()
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
		get_tree().call_group(
				"info menu buttons",
				"add_theme_color_override",
				"font_color",
				Color.WHITE
		)
		# Joystick controls
		# What the hell why is this so much
		if Global.joystick_control:
			if info_menu_column == InfoColumn.SHIPS:
				if Input.is_action_just_pressed("down1"):
					looking_at_ship_info += 1
					$HoverSFX.play()
				if Input.is_action_just_pressed("up1"):
					looking_at_ship_info -= 1
					$HoverSFX.play()
				if Input.is_action_just_pressed("right1"):
					info_menu_column += 1
					$HoverSFX.play()
				hovered_at_ship_info = looking_at_ship_info
			var this_ship: Node3D = friendly_ships.get_child(looking_at_ship_info)
			if info_menu_column == InfoColumn.INFO_TABS:
				if Input.is_action_just_pressed("down1"):
					info_showing += 1
					$HoverSFX.play()
				if Input.is_action_just_pressed("up1"):
					info_showing -= 1
					$HoverSFX.play()
				if Input.is_action_just_pressed("left1"):
					info_menu_column -= 1
					$HoverSFX.play()
				# Peep the horror
				if (
						Input.is_action_just_pressed("right1")
						and (
								(info_showing == InfoTabs.LEVELING
										and this_ship.level < this_ship.MAX_LEVEL)
								or info_showing == InfoTabs.INSTRUCTIONS
								or (info_showing == InfoTabs.MISC
										and (this_ship.type == Global.StarshipTypes.FIGHTER
												or this_ship.type \
														== Global.StarshipTypes.DRONE_COMMAND)
								)
						)
				):
					info_menu_column += 1
					$HoverSFX.play()
			elif info_menu_column == InfoColumn.INFO_VIEW:
				if info_showing == InfoTabs.LEVELING:
					%Information/Leveling/Upgrade/Button.add_theme_color_override(
							"font_color",
							HOVERED_COLOUR
					)
					if Input.is_action_just_pressed("left1"):
						info_menu_column -= 1
						$HoverSFX.play()
					if Input.is_action_just_pressed("1") or Input.is_action_just_pressed("A"):
						upgrade_ship()
						if this_ship.level >= this_ship.MAX_LEVEL:
							info_menu_column -= 1
				elif info_showing == InfoTabs.INSTRUCTIONS:
					if (
							Input.is_action_just_pressed("down1")
							and hovered_instruction < MAX_INSTRUCTION
					):
						hovered_instruction += 1
						$HoverSFX.play()
					if Input.is_action_just_pressed("up1") and hovered_instruction > 0:
						hovered_instruction -= 1
						$HoverSFX.play()
					for instruction in get_tree().get_nodes_in_group("instructions"):
						if instruction.get_meta("index") == hovered_instruction:
							instruction.add_theme_color_override("font_color", HOVERED_COLOUR)
					if Input.is_action_just_pressed("left1"):
						info_menu_column -= 1
						$HoverSFX.play()
					if Input.is_action_just_pressed("1") or Input.is_action_just_pressed("A"):
						if hovered_instruction < MAX_INSTRUCTION:
							ship_action(not bool(hovered_instruction))
						else:
							abandon_ship()
				elif info_showing == InfoTabs.MISC:
					if Input.is_action_just_pressed("left1"):
						if switch_weapon.x == 0:
							info_menu_column -= 1
						else:
							switch_weapon.x = 0
						$HoverSFX.play()
					if Input.is_action_just_pressed("right1"):
						switch_weapon.x = 1
						$HoverSFX.play()
					if Input.is_action_just_pressed("up1") and switch_weapon.y > 0:
						switch_weapon.y -= 1
						$HoverSFX.play()
					if (
							Input.is_action_just_pressed("down1")
							and switch_weapon.y < this_ship.level - 1
					):
						switch_weapon.y += 1
						$HoverSFX.play()
					for button in get_tree().get_nodes_in_group("weapon switchers"):
						if button.get_meta("position") == switch_weapon:
							button.add_theme_color_override("font_color", HOVERED_COLOUR)
							if (
									Input.is_action_just_pressed("1")
									or Input.is_action_just_pressed("A")
							):
								button.emit_signal("pressed")
			info_showing = clampi(info_showing, 0, InfoTabs.MISC)
			info_menu_column = clampi(info_menu_column, 0, InfoColumn.INFO_VIEW)
		looking_at_ship_info = clampi(looking_at_ship_info, 0, friendly_ships.get_child_count() - 1)
	else:
		$FleetInfoMenu.hide()
	
	# Shop menu behaviour
	if shop_showing:
		$Shop.show()
		
		# Item buying UI
		for child in %ItemBuy.get_children():
			var index: int = child.get_index()
			if index > 0:
				child.hide()
				var stylebox: Resource = child.get_theme_stylebox("panel")
				if Global.joystick_control:
					if (
							int(str(child.name)[-1]) - 1 == hovered_shop_button
							and selected_shop_side == 0
					):
						stylebox.border_color = RED_PANEL_HOVER
					else:
						stylebox.border_color = RED_PANEL_NORMAL
				elif index == hovered_shop_button:
					stylebox.border_color = RED_PANEL_HOVER
				else:
					stylebox.border_color = RED_PANEL_NORMAL
		# Information labels
		var child_index: int = 1
		for item in item_catalogue:
			%ItemBuy.get_child(child_index).show()
			%ItemBuy.get_child(child_index).get_node("Row/Col1/Name").text \
					= NAME_TEXT + Global.weapon_list[item]["Name"]
			%ItemBuy.get_child(child_index).get_node("Row/Col1/Type").text \
					= TYPE_TEXT + Global.weapon_types[Global.weapon_list[item]["Type"]]
			%ItemBuy.get_child(child_index).get_node("Row/Col1/Damage").text \
					= DAMAGE_TEXT + str(Global.weapon_list[item]["Damage"]) + HULL_SUFFIX
			%ItemBuy.get_child(child_index).get_node("Row/Col1/Reload").text \
					= RELOAD_TEXT + str(Global.weapon_list[item]["Reload time"]) + SECONDS_SUFFIX
			%ItemBuy.get_child(child_index).get_node("Row/Col1/Value").text \
					= VALUE_TEXT + str(Global.weapon_list[item]["Cost"]) + TECH_SUFFIX
			%ItemBuy.get_child(child_index).get_node("Row/Col2/Text").text \
					= Global.weapon_list[item]["Description"]
			child_index += 1
		
		# Item selling UI
		for child in %ItemSell.get_children():
			var index: int = child.get_index()
			if index > 0:
				child.hide()
				var stylebox: Resource = child.get_theme_stylebox("panel")
				if Global.joystick_control:
					if (
							int(str(child.name)[-1]) - 1 == hovered_shop_button
							and selected_shop_side == 1
					):
						stylebox.border_color = BLUE_PANEL_HOVER
					else:
						stylebox.border_color = BLUE_PANEL_NORMAL
				elif index + %ItemBuy.get_child_count() == hovered_shop_button:
					stylebox.border_color = BLUE_PANEL_HOVER
				else:
					stylebox.border_color = BLUE_PANEL_NORMAL
		# Information labels
		child_index = 1
		for item in Global.fleet_inventory:
			%ItemSell.get_child(child_index).show()
			%ItemSell.get_child(child_index).get_node("Row/Col1/Name").text \
					= NAME_TEXT + Global.weapon_list[item]["Name"]
			%ItemSell.get_child(child_index).get_node("Row/Col1/Type").text \
					= TYPE_TEXT + Global.weapon_types[Global.weapon_list[item]["Type"]]
			%ItemSell.get_child(child_index).get_node("Row/Col1/Value").text \
					= SELL_VALUE_TEXT + str(int((
							ceil(Global.weapon_list[item]["Cost"]) * SELL_MODIFIER
					))) + TECH_SUFFIX
			%ItemSell.get_child(child_index).get_node("Row/Col2/Damage").text \
					= DAMAGE_TEXT + str(Global.weapon_list[item]["Damage"]) + HULL_SUFFIX
			%ItemSell.get_child(child_index).get_node("Row/Col2/Reload").text \
					= RELOAD_TEXT + str(Global.weapon_list[item]["Reload time"]) + SECONDS_SUFFIX
			child_index += 1
		
		# Ship buying UI
		for child in %ShipBuy.get_children():
			var index: int = child.get_index()
			if index > 0:
				child.hide()
				var stylebox: Resource = child.get_theme_stylebox("panel")
				if Global.joystick_control:
					if (
							int(str(child.name)[-1]) - 1 == hovered_shop_button
							and selected_shop_side == 0
					):
						stylebox.border_color = RED_PANEL_HOVER
					else:
						stylebox.border_color = RED_PANEL_NORMAL
				elif index == hovered_shop_button:
					stylebox.border_color = RED_PANEL_HOVER
				else:
					stylebox.border_color = RED_PANEL_NORMAL
		# Information labels
		child_index = 1
		for ship in ship_catalogue:
			%ShipBuy.get_child(child_index).show()
			%ShipBuy.get_child(child_index).get_node("Row/Col1/Name").text \
					= NAME_TEXT + ship["Name"]
			%ShipBuy.get_child(child_index).get_node("Row/Col1/Type").text \
					= TYPE_TEXT + SHIP_CODES[ship["Type"]]
			%ShipBuy.get_child(child_index).get_node("Row/Col1/Value").text \
					= VALUE_TEXT + str(
							Global.starship_base_stats[ship["Type"]]["Cost"]
					) + TECH_SUFFIX
			%ShipBuy.get_child(child_index).get_node("Row/Col2/Text").text = ship["Description"]
			child_index += 1
		
		# Ship selling UI
		for child in %ShipSell.get_children():
			var index: int = child.get_index()
			if index > 0:
				child.hide()
				var stylebox: Resource = child.get_theme_stylebox("panel")
				if Global.joystick_control:
					if (
							int(str(child.name)[-1]) - 1 == hovered_shop_button
							and selected_shop_side == 1
					):
						stylebox.border_color = BLUE_PANEL_HOVER
					else:
						stylebox.border_color = BLUE_PANEL_NORMAL
				elif index + %ShipBuy.get_child_count() == hovered_shop_button:
					stylebox.border_color = BLUE_PANEL_HOVER
				else:
					stylebox.border_color = BLUE_PANEL_NORMAL
		# Information labels
		child_index = 1
		for ship in friendly_ships.get_children():
			# Don't want the player selling off their command ship now, do we
			if ship.type == Global.StarshipTypes.COMMAND_SHIP:
				continue
			%ShipSell.get_child(child_index).show()
			%ShipSell.get_child(child_index).get_node("Row/Col1/Name").text \
					= NAME_TEXT + ship.ship_name
			%ShipSell.get_child(child_index).get_node("Row/Col1/Type").text \
					= TYPE_TEXT + SHIP_CODES[ship.type]
			%ShipSell.get_child(child_index).get_node("Row/Col2/Level").text \
					= LEVEL_TEXT + str(ship.level)
			%ShipSell.get_child(child_index).get_node("Row/Col2/Value").text \
					= SELL_VALUE_TEXT + str(int((
							ceil(Global.starship_base_stats[ship.type]["Cost"]) * SELL_MODIFIER
					) * ship.level)) + TECH_SUFFIX
			child_index += 1
		
		# Controller style shenanigans, once again
		if Global.joystick_control:
			if Input.is_action_just_pressed("up1"):
				hovered_shop_button -= 1
				$HoverSFX.play()
			if Input.is_action_just_pressed("down1"):
				hovered_shop_button += 1
				$HoverSFX.play()
			if Input.is_action_just_pressed("right1"):
				selected_shop_side = 1
				$HoverSFX.play()
			if Input.is_action_just_pressed("left1"):
				selected_shop_side = 0
				$HoverSFX.play()
			
			get_tree().call_group(
					"shopfront select",
					"add_theme_color_override",
					"font_color",
					Color.WHITE
			)
			
			# How it controls depends on which shopfront the player is looking at (items or ships)
			if current_shopfront == Shopfronts.ITEMS:
				# It also depends on which side they're currently on (buying or selling)
				if selected_shop_side == ShopSides.BUYING:
					hovered_shop_button = clampi(hovered_shop_button, -1, len(item_catalogue) - 1)
					if (
							Input.is_action_just_pressed("1")
							or Input.is_action_just_pressed("A")
							and hovered_shop_button >= 0
					):
						for button in get_tree().get_nodes_in_group("item buy"):
							if int(str(button.get_parent().name)[-1]) - 1 == hovered_shop_button:
								button.emit_signal("pressed")
								$PressSFX.play()
								break
				if selected_shop_side == ShopSides.SELLING:
					hovered_shop_button = clampi(
							hovered_shop_button,
							-1,
							len(Global.fleet_inventory) - 1
					)
					if Input.is_action_just_pressed("1") or Input.is_action_just_pressed("A"):
						if hovered_shop_button >= 0:
							for button in get_tree().get_nodes_in_group("item sell"):
								# By the Nine Indentations!
								if (
										int(
												str(button.get_parent().name)[-1]
										) - 1 == hovered_shop_button
								):
									button.emit_signal("pressed")
									$PressSFX.play()
									break
						else:
							_ship_shop()
			elif current_shopfront == Shopfronts.SHIPS:
				if selected_shop_side == ShopSides.BUYING:
					hovered_shop_button = clampi(hovered_shop_button, -1, len(ship_catalogue) - 1)
					if Input.is_action_just_pressed("1") or Input.is_action_just_pressed("A"):
						if hovered_shop_button >= 0:
							for button in get_tree().get_nodes_in_group("ship buy"):
								if (
										int(
												str(button.get_parent().name)[-1]
										) - 1 == hovered_shop_button
								):
									button.emit_signal("pressed")
									$PressSFX.play()
									break
						else:
							_item_shop()
				if selected_shop_side == ShopSides.SELLING:
					var max_shop_button: int = len(Global.fleet) - 2
					hovered_shop_button = clampi(hovered_shop_button, -1, max_shop_button)
					if (
							Input.is_action_just_pressed("1")
							or Input.is_action_just_pressed("A")
							and hovered_shop_button >= 0
					):
						for button in get_tree().get_nodes_in_group("ship sell"):
							if int(str(button.get_parent().name)[-1]) - 1 == hovered_shop_button:
								button.emit_signal("pressed")
								$PressSFX.play()
								break
			# ID for the buttons that change shopfronts
			if hovered_shop_button == -1:
				if selected_shop_side == 0:
					%ItemButton/Button.add_theme_color_override("font_color", HOVERED_COLOUR)
				else:
					%ShipButton/Button.add_theme_color_override("font_color", HOVERED_COLOUR)
	else:
		$Shop.hide()
	
	# Button for universal exiting of menus
	if Input.is_action_just_pressed("universal exit"):
		action_menu_showing = false
		info_menu_showing = false
		galaxy_map_showing = false
		shop_showing = false
		$PressSFX.play()
	
	# For some reason the very first frame does not have a viewport and it generates an error
	if get_viewport() != null:
		prev_mouse_pos = get_global_mouse_position()


# Sets up the dialogue box, with text and dialogue options
func dialogue_set_up(library: int, id: int, bonus_text: String = "") -> void:
	time_paused = true
	# Hide the options by default
	for child in %Options.get_children():
		child.hide()
	option_results = []
	if library == DialogueTypes.WARP_IN:
		%DialogueText.text = warp_in_dialogue[id][1]
		max_option = len(warp_in_dialogue[id][2])
		# Options
		for option in max_option:
			%Options.get_node("Option" + str(option + 1)).text \
					= str(option + 1) + ". " + warp_in_dialogue[id][2][option][0]
			option_results.append(warp_in_dialogue[id][2][option][1])
			%Options.get_node("Option" + str(option + 1)).show()
	elif library == DialogueTypes.RESPONSE:
		%DialogueText.text = response_dialogue[id][0]
		max_option = len(response_dialogue[id][1])
		# Options
		for option in max_option:
			%Options.get_node("Option" + str(option + 1)).text \
					= str(option + 1) + ". " + response_dialogue[id][1][option][0]
			option_results.append(response_dialogue[id][1][option][1])
			%Options.get_node("Option" + str(option + 1)).show()
	elif library == DialogueTypes.ENCOUNTER_WIN:
		%DialogueText.text = encounter_win_dialogues[id][0]
		max_option = len(encounter_win_dialogues[id][1])
		# Options
		for option in max_option:
			%Options.get_node("Option" + str(option + 1)).text \
					= str(option + 1) + ". " + encounter_win_dialogues[id][1][option][0]
			option_results.append(encounter_win_dialogues[id][1][option][1])
			%Options.get_node("Option" + str(option + 1)).show()
	elif library == DialogueTypes.INTRO:
		%DialogueText.text = intro_dialogues[id][0]
		max_option = len(intro_dialogues[id][1])
		# Options
		for option in max_option:
			%Options.get_node("Option" + str(option + 1)).text \
					= str(option + 1) + ". " + intro_dialogues[id][1][option][0]
			option_results.append(intro_dialogues[id][1][option][1])
			%Options.get_node("Option" + str(option + 1)).show()
	elif library == DialogueTypes.TUTORIAL:
		%DialogueText.text = tutorial_dialogues[id][0]
		max_option = len(tutorial_dialogues[id][1])
		# Options
		for option in max_option:
			%Options.get_node("Option" + str(option + 1)).text \
					= str(option + 1) + ". " + tutorial_dialogues[id][1][option][0]
			option_results.append(tutorial_dialogues[id][1][option][1])
			%Options.get_node("Option" + str(option + 1)).show()
	elif library == DialogueTypes.ITEM_WIN:
		%DialogueText.text = item_win_dialogues[id][0] + bonus_text
		max_option = len(item_win_dialogues[id][1])
		# Options
		for option in max_option:
			%Options.get_node("Option" + str(option + 1)).text \
					= str(option + 1) + ". " + item_win_dialogues[id][1][option][0]
			option_results.append(item_win_dialogues[id][1][option][1])
			%Options.get_node("Option" + str(option + 1)).show()
	elif library == DialogueTypes.ENEMY_RUNNING:
		%DialogueText.text = enemy_running_dialogue[id][0]
		max_option = len(enemy_running_dialogue[id][1])
		# Options
		for option in max_option:
			%Options.get_node("Option" + str(option + 1)).text \
					= str(option + 1) + ". " + enemy_running_dialogue[id][1][option][0]
			option_results.append(enemy_running_dialogue[id][1][option][1])
			%Options.get_node("Option" + str(option + 1)).show()
	elif library == DialogueTypes.ENEMY_RAN_AWAY:
		%DialogueText.text = enemy_ran_away_dialogues[id][0]
		max_option = len(enemy_ran_away_dialogues[id][1])
		# Options
		for option in max_option:
			%Options.get_node("Option" + str(option + 1)).text \
					= str(option + 1) + ". " + enemy_ran_away_dialogues[id][1][option][0]
			option_results.append(enemy_ran_away_dialogues[id][1][option][1])
			%Options.get_node("Option" + str(option + 1)).show()
	$Dialogue.show()
	dialogue_showing = true
	ready_to_select = true


# Open/close galaxy map
func _galaxy_map() -> void:
	if main.warp_charge >= MAX_WARP_CHARGE and not warping:
		action_menu_showing = false
		info_menu_showing = false
		dialogue_showing = false
		shop_showing = false
		galaxy_map_showing = not galaxy_map_showing
		$PressSFX.play()
		if galaxy_map_showing:
			var database: Dictionary = Global.galaxy_data[Global.current_system]
			if database["position"].x > MAP_AUTO_SCROLL_THRESHOLD:
				$GalaxyMap/Tokens.position.x = MAP_SCROLL_OFFSET - database["position"].x
			else:
				$GalaxyMap/Tokens.position.x = MAP_DEFAULT_SCROLL
			%Cursor.position = database["position"]


# Open/close ship action menu
func _action_menu() -> void:
	if not warping and not galaxy_map_showing:
		info_menu_showing = false
		dialogue_showing = false
		shop_showing = false
		action_menu_showing = not action_menu_showing
		$PressSFX.play()


# Pause/unpause time
func _time_pause() -> void:
	if not galaxy_map_showing and not dialogue_showing and not warping:
		time_paused = not time_paused
		$PressSFX.play()


# Pause game
func _pause() -> void:
	if not warping:
		$PauseMenu.show()
		$PauseMenu/UnpauseTimer.start()
		get_tree().paused = true


# Open/close fleet information menu
func _info_menu() -> void:
	if not warping:
		galaxy_map_showing = false
		action_menu_showing = false
		dialogue_showing = false
		shop_showing = false
		info_menu_showing = not info_menu_showing
		$PressSFX.play()


# Upgrade selected ship
func upgrade_ship() -> void:
	var ship: Node3D = friendly_ships.get_child(looking_at_ship_info)
	var price: int = Global.upgrade_costs[ship.type][ship.level - 1]
	if Global.resources >= price:
		resources(-price)
		ship.upgrade()
		$PressSFX.play()


# Set up the shop, after a small delay
func _on_shop_setup_timeout() -> void:
	# Establish data, if a shop is actually present
	if "shop presence" in main.system_properties:
		if Global.current_system in Global.visited_systems and len(Global.visited_systems) > 1:
			item_catalogue = Global.galaxy_data[Global.current_system]["item shop"]
			ship_catalogue = Global.galaxy_data[Global.current_system]["ship shop"]
		else:
			$ControlTips/VBoxContainer/Main/AccessShop.show()
			for item in len(item_catalogue):
				item_catalogue[item] = randi_range(0, len(Global.weapon_list) - 1)
			for ship in len(ship_catalogue):
				ship_catalogue[ship]["Type"] = randi_range(
						Global.StarshipTypes.FIGHTER,
						Global.StarshipTypes.DRONE_COMMAND
				)
				ship_catalogue[ship]["Name"] = Global.possible_names.pop_at(
						randi_range(0, len(Global.possible_names) - 1)
				)
				ship_catalogue[ship]["Description"] = shop_ship_descriptions.pick_random()


# Open/close shop
func _shop() -> void:
	var shop_in_system: bool = "shop presence" in main.system_properties
	if not warping and shop_in_system:
		galaxy_map_showing = false
		action_menu_showing = false
		info_menu_showing = false
		dialogue_showing = false
		shop_showing = not shop_showing
		$PressSFX.play()


# Hide/show controls
func _hide_controls() -> void:
	if (
			not Global.joystick_control
			or (Global.joystick_control
					and not action_menu_showing
					and not info_menu_showing
					and not galaxy_map_showing
					and not dialogue_showing
					and not shop_showing)
	):
		Global.controls_showing = not Global.controls_showing
		$PressSFX.play()


# Switch to the item shop
func _item_shop() -> void:
	$Shop/VBoxContainer/HBoxContainer/ShipShop.hide()
	$Shop/VBoxContainer/HBoxContainer/ItemShop.show()
	current_shopfront = 0
	$PressSFX.play()


# Switch to the ship shop (I love that I named it that)
func _ship_shop() -> void:
	$Shop/VBoxContainer/HBoxContainer/ItemShop.hide()
	$Shop/VBoxContainer/HBoxContainer/ShipShop.show()
	current_shopfront = 1
	$PressSFX.play()


# Small interval before showing the warp in dialogue
func _on_warp_in_dialogue_timeout() -> void:
	# Warp in dialogue isn't shown if the system has already been visited by the player
	if main.warp_in_dialogue_needed:
		if intro_dialogue:
			# The tutorial has its own dialogue
			if Global.tutorial:
				dialogue_set_up(DialogueTypes.INTRO, 1)
			else:
				dialogue_set_up(DialogueTypes.INTRO, 0)
			intro_dialogue = false
		else:
			# Search through options for the warp in dialogue and find which ones are
			# appropriate for this system
			var possible_dialogues: Array = []
			for dialogue_set in warp_in_dialogue:
				if dialogue_set[0] == main.system_properties:
					possible_dialogues.append(warp_in_dialogue.find(dialogue_set))
			dialogue_set_up(DialogueTypes.WARP_IN, possible_dialogues.pick_random())
	else:
		close(Global.galaxy_data[Global.current_system]["enemy presence"])


# Called when either fuel or resources are spent or gained
func quantity_change(quantity_type: int, up: bool) -> void:
	if quantity_type == ResourceType.TECH:
		if up:
			%ResourcesLabel.add_theme_color_override("font_color", Color.GREEN)
		else:
			%ResourcesLabel.add_theme_color_override("font_color", Color.RED)
	if quantity_type == ResourceType.FUEL:
		if up:
			%FuelLabel.add_theme_color_override("font_color", Color.GREEN)
		else:
			%FuelLabel.add_theme_color_override("font_color", Color.RED)


# Close the dialogue box
func close(combat: bool, end: bool = false) -> void:
	$Dialogue.hide()
	dialogue_showing = false
	time_paused = false
	# Is combat starting now?
	if combat:
		Global.in_combat = true
	else:
		main.warp_charge = MAX_WARP_CHARGE
	# Is this the end of the game?
	if end:
		quit_to_menu()


# Give (or remove) resources or fuel
func resources(value: int, resource_type: int = 0, dialogue: bool = false, response: int = 0, library: int = 1) -> void:
	if resource_type == ResourceType.TECH:
		Global.resources += value
	elif resource_type == ResourceType.FUEL:
		Global.fuel += value
	quantity_change(resource_type, value >= 0)
	if dialogue:
		dialogue_set_up(library, response)


# Player selects a dialogue option
func select_dialogue(n: int) -> void:
	var args: Array = []
	# Check which kind of call needs to be made (arguments or no arguments)
	if len(option_results[n - 1]) > 1:
		# Function call has argument(s)
		for result in len(option_results[n - 1]) - 1:
			args.append(option_results[n - 1][result + 1])
		callv(option_results[n - 1][0], args)
	else:
		# Zero argument function call
		call(option_results[n - 1][0])
	$PressSFX.play()


# Hover a friendly ship in the action menu
func hover_ship(num: int) -> void:
	hovered_ship = num


# Select a friendly ship in the action menu
func select_ship(num: int = -1) -> void:
	if num != -1:
		selected_ship = num
	targeting_mode = friendly_ships.get_child(selected_ship).type
	%Instruction/Label.text = TARGETING_OPTIONS[targeting_mode]


# Hover a target in the action menu
func hover_target(num: int) -> void:
	hovered_target = num


# Select a target in the action menu
func select_target() -> void:
	if friendly_ships.get_child(selected_ship) != null:
		friendly_ships.get_child(selected_ship).new_target(hovered_target)
	$PressSFX.play()


# Hover on a ship in the info menu
func hover_info(num: int) -> void:
	hovered_at_ship_info = num
	$HoverSFX.play()


# Select a ship in the info menu
func select_info(num: int) -> void:
	looking_at_ship_info = num
	$PressSFX.play()


# Hover a shop button
func hover_shop(num: int) -> void:
	hovered_shop_button = num


# Buy an item
func buy_item(num: int) -> void:
	var price: int = Global.weapon_list[item_catalogue[num]]["Cost"]
	if len(Global.fleet_inventory) < Global.max_inventory and Global.resources >= price:
		resources(-price)
		Global.fleet_inventory.append(item_catalogue.pop_at(num))
	$PressSFX.play()


# Sell an item from the inventory
func sell_item(num: int) -> void:
	resources(ceil(Global.weapon_list[Global.fleet_inventory.pop_at(num)]["Cost"] * SELL_MODIFIER))
	$PressSFX.play()


# Buy a ship
func buy_ship(num: int) -> void:
	var price: int = Global.starship_base_stats[ship_catalogue[num]["Type"]]["Cost"]
	if len(Global.fleet) < Global.MAX_FLEET_SIZE and Global.resources >= price:
		resources(-price)
		Global.create_new_starship(ship_catalogue[num]["Type"], ship_catalogue[num]["Name"])
		ship_catalogue.remove_at(num)
	$PressSFX.play()


# Sell a ship from the fleet
func sell_ship(num: int) -> void:
	var sold_ship: Node3D = friendly_ships.get_child(num)
	resources((
			ceil(Global.starship_base_stats[sold_ship.type]["Cost"]) * SELL_MODIFIER
	) * sold_ship.level)
	sold_ship.hull = 0
	$PressSFX.play()


# Switch a ship between being active and inactive
func ship_action(activate: bool) -> void:
	if friendly_ships.get_child(looking_at_ship_info) != null:
		friendly_ships.get_child(looking_at_ship_info).active = activate
		$PressSFX.play()


# Abandon a ship and remove it from the player's fleet
func abandon_ship() -> void:
	if friendly_ships.get_child(looking_at_ship_info) != null:
		friendly_ships.get_child(looking_at_ship_info).hull = 0
		$PressSFX.play()


# Win an enemy encounter and get rewards
func win_encounter() -> void:
	Global.galaxy_data[Global.current_system]["enemy presence"] = false
	# Tech
	resources(randi_range(
			TECH_REWARDS.x * main.enemy_ship_count,
			TECH_REWARDS.y * main.enemy_ship_count
	))
	# Fuel
	resources(
			randi_range(FUEL_REWARDS.x, FUEL_REWARDS.y * len(Global.fleet) - 1),
			ResourceType.FUEL
	)
	# Potential item
	if (
			randi_range(0, REWARD_CHANCES) >= Global.ITEM_WIN_THRESHOLD
			and len(Global.fleet_inventory) < Global.max_inventory
	):
		var weapon_won: int = Global.WINNABLE_WEAPONS.pick_random()
		Global.fleet_inventory.append(weapon_won)
		dialogue_set_up(
				DialogueTypes.ITEM_WIN,
				len(item_win_dialogues) - 1,
				Global.weapon_list[weapon_won]["Name"] + "."
		)
	elif enemy_ran_away:
		dialogue_set_up(DialogueTypes.ENEMY_RAN_AWAY, len(enemy_ran_away_dialogues) - 1)
	else:
		dialogue_set_up(DialogueTypes.ENCOUNTER_WIN, len(encounter_win_dialogues) - 1)


# Lose the game
func lose() -> void:
	Global.playing = false
	galaxy_map_showing = false
	$GalaxyMap.hide()
	action_menu_showing = false
	$ShipActionMenu.hide()
	info_menu_showing = false
	$FleetInfoMenu.hide()
	dialogue_set_up(DialogueTypes.RESPONSE, LOSE_DIALOGUE_ID)


# Quit to the main menu
func quit_to_menu() -> void:
	var main_menu: String = "res://Menus/main_menu.tscn"
	# Adds the current system to the database
	Global.playing = false
	Global.menu_music_progress = 0.0
	get_tree().change_scene_to_file(main_menu)


# Restart the game
func restart() -> void:
	Global.new_game()
