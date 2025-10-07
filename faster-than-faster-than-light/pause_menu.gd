extends Control


var unpause_ready: bool = false
var current_selection: int = 0

const MAX_SELECTION: int = 2
const BUTTON_COLOUR_NORMAL: Color = Color(1.0, 1.0, 1.0)
const BUTTON_COLOUR_HOVER: Color = Color(0.0, 0.749, 1.0)


func _ready() -> void:
	%MusicVolume/HSlider.value = Global.music_volume
	%SFXVolume/HSlider.value = Global.sfx_volume


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause") and get_tree().paused and unpause_ready:
		_on_continue_pressed()
	if Input.is_action_just_pressed("debug quit"):
		get_tree().quit()
	
	Global.music_volume = %MusicVolume/HSlider.value
	Global.sfx_volume = %SFXVolume/HSlider.value
	
	if Global.joystick_control:
		%Gameplay/ControlMode.text = "CONTROL MODE: ARCADE"
		
		if Input.is_action_just_pressed("down1") or Input.is_action_just_pressed("down2"):
			current_selection += 1
		if Input.is_action_just_pressed("up1") or Input.is_action_just_pressed("up2"):
			current_selection -= 1
		
		current_selection = clampi(current_selection, 0, MAX_SELECTION)
		
		if $Main.visible:
			if current_selection == 0:
				$Main/Continue/Button.add_theme_color_override("font_color", BUTTON_COLOUR_HOVER)
				$Main/Settings/Button.add_theme_color_override("font_color", BUTTON_COLOUR_NORMAL)
				$Main/Quit/Button.add_theme_color_override("font_color", BUTTON_COLOUR_NORMAL)
				if Input.is_action_just_pressed("1") or Input.is_action_just_pressed("A"):
					_on_continue_pressed()
			if current_selection == 1:
				$Main/Continue/Button.add_theme_color_override("font_color", BUTTON_COLOUR_NORMAL)
				$Main/Settings/Button.add_theme_color_override("font_color", BUTTON_COLOUR_HOVER)
				$Main/Quit/Button.add_theme_color_override("font_color", BUTTON_COLOUR_NORMAL)
				if Input.is_action_just_pressed("1") or Input.is_action_just_pressed("A"):
					_on_settings_pressed()
			if current_selection == 2:
				$Main/Continue/Button.add_theme_color_override("font_color", BUTTON_COLOUR_NORMAL)
				$Main/Settings/Button.add_theme_color_override("font_color", BUTTON_COLOUR_NORMAL)
				$Main/Quit/Button.add_theme_color_override("font_color", BUTTON_COLOUR_HOVER)
				if Input.is_action_just_pressed("1") or Input.is_action_just_pressed("A"):
					_on_quit_pressed()
		elif $Settings.visible:
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
	else:
		%Gameplay/ControlMode.text = "CONTROL MODE: KEYBOARD/MOUSE"
	
	if Global.dual_joysticks:
		%Gameplay/JoystickMode.text = "JOYSTICK MODE: DUAL"
	else:
		%Gameplay/JoystickMode.text = "JOYSTICK MODE: SINGLE"
	
	%MusicVolume/Value.text = str(int(Global.music_volume))
	%SFXVolume/Value.text = str(int(Global.sfx_volume))


func _on_continue_pressed() -> void:
	hide()
	$Main.show()
	$Settings.hide()
	unpause_ready = false
	get_tree().paused = false


func _on_settings_pressed() -> void:
	$Main.hide()
	$Settings.show()
	current_selection = 0


func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Menus/main_menu.tscn")


func _on_unpause_timer_timeout() -> void:
	unpause_ready = true


func _on_back_pressed() -> void:
	$Settings.hide()
	$Main.show()
	current_selection = 0


func _on_control_mode_pressed() -> void:
	Global.joystick_control = not Global.joystick_control


func _on_joystick_mode_pressed() -> void:
	Global.dual_joysticks = not Global.dual_joysticks
