extends Control


var unpause_ready: bool = false
var current_selection: int = 0

const MAX_SELECTION: int = 2
const BUTTON_COLOUR_NORMAL: Color = Color(1.0, 1.0, 1.0)
const BUTTON_COLOUR_HOVER: Color = Color(0.0, 0.749, 1.0)

const CONTROL_MODE_TEXTS: Array = ["CONTROL MODE: KEYBOARD/MOUSE", "CONTROL MODE: ARCADE"]
const JOYSTICK_MODE_TEXTS: Array = ["JOYSTICK MODE: SINGLE", "JOYSTICK MODE: DUAL"]

enum PauseButtons {
	CONTINUE,
	SETTINGS,
	QUIT
}

enum SettingsButtons {
	MODE,
	JOYSTICKS,
	BACK
}


func _ready() -> void:
	# Establish saved settings values
	%MusicVolume/HSlider.value = Global.music_volume
	%SFXVolume/HSlider.value = Global.sfx_volume


func _process(_delta: float) -> void:
	# Unpausing
	if Input.is_action_just_pressed("pause") and get_tree().paused and unpause_ready:
		_on_continue_pressed()
	# Quick quit
	if Input.is_action_just_pressed("debug quit"):
		get_tree().quit()
	
	# Set audio bus volumes
	Global.music_volume = %MusicVolume/HSlider.value
	Global.sfx_volume = %SFXVolume/HSlider.value
	
	%Gameplay/ControlMode.text = CONTROL_MODE_TEXTS[int(Global.joystick_control)]
	%Gameplay/JoystickMode.text = JOYSTICK_MODE_TEXTS[int(Global.dual_joysticks)]
	
	# Button selection
	if Global.joystick_control:
		if Input.is_action_just_pressed("down1") or Input.is_action_just_pressed("down2"):
			current_selection += 1
		if Input.is_action_just_pressed("up1") or Input.is_action_just_pressed("up2"):
			current_selection -= 1
		
		current_selection = clampi(current_selection, 0, MAX_SELECTION)
		
		# Check which menu is currently being looked at
		if $Main.visible:
			if (
					(Input.is_action_just_pressed("6")
							or Input.is_action_just_pressed("F"))
					and unpause_ready
			):
				_on_continue_pressed()
			
			if current_selection == PauseButtons.CONTINUE:
				$Main/Continue/Button.add_theme_color_override("font_color", BUTTON_COLOUR_HOVER)
				$Main/Settings/Button.add_theme_color_override("font_color", BUTTON_COLOUR_NORMAL)
				$Main/Quit/Button.add_theme_color_override("font_color", BUTTON_COLOUR_NORMAL)
				if Input.is_action_just_pressed("1") or Input.is_action_just_pressed("A"):
					_on_continue_pressed()
			elif current_selection == PauseButtons.SETTINGS:
				$Main/Continue/Button.add_theme_color_override("font_color", BUTTON_COLOUR_NORMAL)
				$Main/Settings/Button.add_theme_color_override("font_color", BUTTON_COLOUR_HOVER)
				$Main/Quit/Button.add_theme_color_override("font_color", BUTTON_COLOUR_NORMAL)
				if Input.is_action_just_pressed("1") or Input.is_action_just_pressed("A"):
					_on_settings_pressed()
			elif current_selection == PauseButtons.QUIT:
				$Main/Continue/Button.add_theme_color_override("font_color", BUTTON_COLOUR_NORMAL)
				$Main/Settings/Button.add_theme_color_override("font_color", BUTTON_COLOUR_NORMAL)
				$Main/Quit/Button.add_theme_color_override("font_color", BUTTON_COLOUR_HOVER)
				if Input.is_action_just_pressed("1") or Input.is_action_just_pressed("A"):
					_on_quit_pressed()
		elif $Settings.visible:
			if current_selection == SettingsButtons.MODE:
				%Gameplay/ControlMode.add_theme_color_override("font_color", BUTTON_COLOUR_HOVER)
				%Gameplay/JoystickMode.add_theme_color_override("font_color", BUTTON_COLOUR_NORMAL)
				%Back/Button.add_theme_color_override("font_color", BUTTON_COLOUR_NORMAL)
				# Edit music volume slider
				if Input.is_action_pressed("left1") or Input.is_action_pressed("left2"):
					%MusicVolume/HSlider.value -= 1
				if Input.is_action_pressed("right1") or Input.is_action_pressed("right2"):
					%MusicVolume/HSlider.value += 1
				if Input.is_action_just_pressed("1") or Input.is_action_just_pressed("A"):
					_on_control_mode_pressed()
			elif current_selection == SettingsButtons.JOYSTICKS:
				%Gameplay/ControlMode.add_theme_color_override("font_color", BUTTON_COLOUR_NORMAL)
				%Gameplay/JoystickMode.add_theme_color_override("font_color", BUTTON_COLOUR_HOVER)
				%Back/Button.add_theme_color_override("font_color", BUTTON_COLOUR_NORMAL)
				# Edit SFX volume slider
				if Input.is_action_pressed("left1") or Input.is_action_pressed("left2"):
					%SFXVolume/HSlider.value -= 1
				if Input.is_action_pressed("right1") or Input.is_action_pressed("right2"):
					%SFXVolume/HSlider.value += 1
				if Input.is_action_just_pressed("1") or Input.is_action_just_pressed("A"):
					_on_joystick_mode_pressed()
			elif current_selection == SettingsButtons.BACK:
				%Gameplay/ControlMode.add_theme_color_override("font_color", BUTTON_COLOUR_NORMAL)
				%Gameplay/JoystickMode.add_theme_color_override("font_color", BUTTON_COLOUR_NORMAL)
				%Back/Button.add_theme_color_override("font_color", BUTTON_COLOUR_HOVER)
				if Input.is_action_just_pressed("1") or Input.is_action_just_pressed("A"):
					_on_back_pressed()
	
	%MusicVolume/Value.text = str(int(Global.music_volume))
	%SFXVolume/Value.text = str(int(Global.sfx_volume))


func _on_continue_pressed() -> void:
	# Continue playing
	hide()
	$Main.show()
	$Settings.hide()
	unpause_ready = false
	get_tree().paused = false


func _on_settings_pressed() -> void:
	# Open settings
	$Main.hide()
	$Settings.show()
	current_selection = SettingsButtons.MODE


func _on_quit_pressed() -> void:
	# Quit to menu
	var main_menu: String = "res://Menus/main_menu.tscn"
	Global.menu_music_progress = 0.0
	get_tree().paused = false
	get_tree().change_scene_to_file(main_menu)


# Delays when the player can 
func _on_unpause_timer_timeout() -> void:
	unpause_ready = true


# Back to pause menu
func _on_back_pressed() -> void:
	$Settings.hide()
	$Main.show()
	current_selection = PauseButtons.CONTINUE


# Switch control modes
func _on_control_mode_pressed() -> void:
	Global.joystick_control = not Global.joystick_control


# Switch joystick setups
func _on_joystick_mode_pressed() -> void:
	Global.dual_joysticks = not Global.dual_joysticks
