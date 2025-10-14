extends Control


var current_selection: int = 0

const MAX_SELECTION: int = 2
const BUTTON_COLOUR_NORMAL: Color = Color(1.0, 1.0, 1.0)
const BUTTON_COLOUR_HOVER: Color = Color(0.0, 0.749, 1.0)

const CONTROL_MODE_TEXTS: Array = ["CONTROL MODE: KEYBOARD/MOUSE", "CONTROL MODE: ARCADE"]
const JOYSTICK_MODE_TEXTS: Array = ["JOYSTICK MODE: SINGLE", "JOYSTICK MODE: DUAL"]


func _ready() -> void:
	%MusicVolume/HSlider.value = Global.music_volume
	%SFXVolume/HSlider.value = Global.sfx_volume


func _on_back_pressed() -> void:
	var main_menu: String = "res://Menus/main_menu.tscn"
	get_tree().change_scene_to_file(main_menu)


func _process(_delta: float) -> void:
	Global.music_volume = %MusicVolume/HSlider.value
	Global.sfx_volume = %SFXVolume/HSlider.value
	
	%Gameplay/ControlMode.text = CONTROL_MODE_TEXTS[int(Global.joystick_control)]
	%Gameplay/JoystickMode.text = JOYSTICK_MODE_TEXTS[int(Global.dual_joysticks)]
	
	if Global.joystick_control:
		if Input.is_action_just_pressed("down1") or Input.is_action_just_pressed("down2"):
			current_selection += 1
			if current_selection > MAX_SELECTION:
				current_selection = 0
		if Input.is_action_just_pressed("up1") or Input.is_action_just_pressed("up2"):
			current_selection -= 1
			if current_selection < 0:
				current_selection = MAX_SELECTION
		
		if current_selection == 0:
			%Gameplay/ControlMode.add_theme_color_override("font_color", BUTTON_COLOUR_HOVER)
			%Gameplay/JoystickMode.add_theme_color_override("font_color", BUTTON_COLOUR_NORMAL)
			%Back/Button.add_theme_color_override("font_color", BUTTON_COLOUR_NORMAL)
			if Input.is_action_pressed("left1") or Input.is_action_pressed("left2"):
				%MusicVolume/HSlider.value -= 1
			if Input.is_action_pressed("right1") or Input.is_action_pressed("right2"):
				%MusicVolume/HSlider.value += 1
			if Input.is_action_just_pressed("1") or Input.is_action_just_pressed("A"):
				_on_control_mode_pressed()
		elif current_selection == 1:
			%Gameplay/ControlMode.add_theme_color_override("font_color", BUTTON_COLOUR_NORMAL)
			%Gameplay/JoystickMode.add_theme_color_override("font_color", BUTTON_COLOUR_HOVER)
			%Back/Button.add_theme_color_override("font_color", BUTTON_COLOUR_NORMAL)
			if Input.is_action_pressed("left1") or Input.is_action_pressed("left2"):
				%SFXVolume/HSlider.value -= 1
			if Input.is_action_pressed("right1") or Input.is_action_pressed("right2"):
				%SFXVolume/HSlider.value += 1
			if Input.is_action_just_pressed("1") or Input.is_action_just_pressed("A"):
				_on_joystick_mode_pressed()
		else:
			%Gameplay/ControlMode.add_theme_color_override("font_color", BUTTON_COLOUR_NORMAL)
			%Gameplay/JoystickMode.add_theme_color_override("font_color", BUTTON_COLOUR_NORMAL)
			%Back/Button.add_theme_color_override("font_color", BUTTON_COLOUR_HOVER)
			if Input.is_action_just_pressed("1") or Input.is_action_just_pressed("A"):
				_on_back_pressed()
	
	%MusicVolume/Value.text = str(int(Global.music_volume))
	%SFXVolume/Value.text = str(int(Global.sfx_volume))


func _on_control_mode_pressed() -> void:
	Global.joystick_control = not Global.joystick_control


func _on_joystick_mode_pressed() -> void:
	Global.dual_joysticks = not Global.dual_joysticks
