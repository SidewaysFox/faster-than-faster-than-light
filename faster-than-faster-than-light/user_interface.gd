extends Control


@onready var main: Node = get_node("/root/Space")
@export var galaxy_map_token: PackedScene
var fade_mode: int = -1
var cursor_speed: float = 250
var galaxy_map_showing: bool = false
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
	for i in Global.galaxy_data:
		var new_token: Node = galaxy_map_token.instantiate()
		new_token.id = i[0]
		new_token.position = i[1]
		$GalaxyMap/Tokens.add_child(new_token)


func _process(delta: float) -> void:
	if Input.is_action_pressed("debug"):
		$FPS.show()
	else:
		$FPS.hide()
	$FPS.text = "FPS: " + str(1 / delta)
	
	$ScreenFade.color.a += fade_mode * delta
	$ScreenFade.color.a = clamp($ScreenFade.color.a, 0, 1)
	
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
	elif Input.is_action_just_pressed("4") or Input.is_action_just_pressed("D"):
		galaxy_map_showing = not galaxy_map_showing
		if galaxy_map_showing:
			if Global.galaxy_data[Global.current_system][1].x > 900:
				$GalaxyMap/Tokens.position.x = 600 - Global.galaxy_data[Global.current_system][1].x
			%Cursor.position = Global.galaxy_data[Global.current_system][1]
	if galaxy_map_showing:
		$GalaxyMap.show()
		if Input.is_action_pressed("right2"):
			$GalaxyMap/Tokens.position.x -= 400 * delta * Global.joystick_sens
		if Input.is_action_pressed("left2"):
			$GalaxyMap/Tokens.position.x += 400 * delta * Global.joystick_sens
		%Cursor.position += Vector2(Input.get_axis("left1", "right1"), Input.get_axis("up1", "down1")) * cursor_speed * Global.joystick_sens * delta
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
			if (Input.is_action_just_pressed("1") or Input.is_action_just_pressed("A")) and in_warp_range:
				galaxy_map_showing = false
				Global.new_system(closest_token[2])
				await get_tree().create_timer(1).timeout
				main.commence_warp()
				await get_tree().create_timer(2).timeout
				fade_mode = 1
				await get_tree().create_timer(3).timeout
				main.get_tree().reload_current_scene()
		$GalaxyMap/Tokens.position.x = clampf($GalaxyMap/Tokens.position.x, -2040.0, 45.0)
		%Cursor.global_position.x = clampf(%Cursor.global_position.x, 385.0, 1535.0)
		%Cursor.global_position.y = clampf(%Cursor.global_position.y, 256.0, 824.0)
	else:
		$GalaxyMap.hide()


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
	dialogue_showing = false


func _on_warp_in_dialogue_timeout() -> void:
	# Search through options for the warp in dialogue and find which ones are appropriate for this system
	var possible_dialogues: Array = []
	for i in warp_in_dialogue:
		if i[0] == main.system_properties:
			possible_dialogues.append(warp_in_dialogue.find(i))
	dialogue_set_up(0, possible_dialogues.pick_random())
	$Dialogue.show()
	dialogue_showing = true
