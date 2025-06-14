extends Control


@onready var main: Node = get_node("/root/Space")
var dialogue_showing: bool = true
var max_option: int = 3
var current_dialogue_selection: int = 1
var option_results: Array


var warp_in_dialogue: Array = [ # Conditions, main text, [option, result]
	[[1],
	"As your fleet exits its jump, you take in the picturesque scenery around you.",
	[["Enjoy the view as your warp drives charge up once more.", "close"]]
	],
	[[1],
	"You wait with bated breath, half expecting a rebel ambush as you exit warp, but none comes. You live another day.",
	[["Let's not wait around. Charge up the warp drives.", "close"]]
	],
	[[1],
	"Although this system is devoid of anything of particular interest to your fleet, you can't help but remain apprehensive about your task and the rebel fleet chasing you. In these distant reaches of space, it feels like everything wants you dead.",
	[["Play some cards with your crew to ease your nerves while you wait for the warp drives to charge.", "close"], ["Remain alone for the time being.", "close"]]
	],
	[[2],
	"As your fleet exits its jump, you see two stars locked in each others' orbits. You spend a moment taking a deep breath, before returning to your duties on deck.",
	[["Enjoy the view as your warp drives charge up once more.", "close"]]
	],
	[[3],
	"As your fleet exits its jump, you are surprised to find you and your fleet amongst a trinary star system, a rare sight for anyone not part of the navy.",
	[["Enjoy the view as your warp drives charge up once more.", "close"]]
	],
	[[1, "star proximity"],
	"As you exit warp, you realise you've ended up dangerously close to this system's star. Your ships could be in danger if you linger for too long.",
	[["Hope the star doesn't flare up while you wait for your warp drives to charge.", "close"]]
	],
	[[2, "star proximity"],
	"The binary system of stars you've just warped into makes it hard to miss the fact that you've come in far too close for comfort to one of them.",
	[["Hope the star doesn't flare up while you wait for your warp drives to charge.", "close"]]
	],
	[[3, "star proximity"],
	"You find yourself and your fleet in a trinary system, but your close proximity to one of the stars unfortunately means you cannot affort to take in the view.",
	[["Hope the star doesn't flare up while you wait for your warp drives to charge.", "close"]]
	],
]


func _ready() -> void:
	$Dialogue.hide()


func _process(delta: float) -> void:
	if dialogue_showing:
		if Input.is_action_just_pressed("up1") or Input.is_action_just_pressed("up2"):
			current_dialogue_selection -= 1
			if current_dialogue_selection < 1:
				current_dialogue_selection = max_option
		if Input.is_action_just_pressed("down1") or Input.is_action_just_pressed("down2"):
			current_dialogue_selection += 1
			if current_dialogue_selection > max_option:
				current_dialogue_selection = 1
		if Input.is_action_just_pressed("1") or Input.is_action_just_pressed("A"):
			call(option_results[current_dialogue_selection - 1])
		for i in max_option:
			if i + 1 == current_dialogue_selection:
				%Options.get_node("Option" + str(i + 1)).add_theme_color_override("font_color", Color(0, 0.75, 1.0))
			else:
				%Options.get_node("Option" + str(i + 1)).add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))


func dialogue_set_up(library: int, id: int) -> void:
	for child in %Options.get_children():
		child.hide()
	option_results = []
	if library == 0:
		%DialogueText.text = warp_in_dialogue[id][1]
		max_option = len(warp_in_dialogue[id][2])
		for i in len(warp_in_dialogue[id][2]):
			%Options.get_node("Option" + str(i + 1)).text = str(i + 1) + ". " + warp_in_dialogue[id][2][i][0]
			option_results.append(warp_in_dialogue[id][2][i][1])
			%Options.get_node("Option" + str(i + 1)).show()


# Close the dialogue box
func close() -> void:
	$Dialogue.hide()


func _on_warp_in_dialogue_timeout() -> void:
	# Search through options for the warp in dialogue and find which ones are appropriate for this system
	var possible_dialogues: Array = []
	for i in warp_in_dialogue:
		if i[0] == main.system_properties:
			possible_dialogues.append(warp_in_dialogue.find(i))
	dialogue_set_up(0, possible_dialogues.pick_random())
	$Dialogue.show()
