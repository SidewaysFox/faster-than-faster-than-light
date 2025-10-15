extends Control


@onready var music: AudioStreamPlayer = get_node("/root/Settings/Music/")
var current_selection: int = 0

const BUTTON_COLOUR_NORMAL: Color = Color(1.0, 1.0, 1.0)
const BUTTON_COLOUR_HOVER: Color = Color(0.0, 0.749, 1.0)
const CONTROL_MODE_TEXTS: Array = ["CONTROL MODE: KEYBOARD/MOUSE", "CONTROL MODE: ARCADE"]
const JOYSTICK_MODE_TEXTS: Array = ["JOYSTICK MODE: SINGLE", "JOYSTICK MODE: DUAL"]

enum SettingsButtons {
	MODE,
	JOYSTICKS,
	BACK
}


func _ready() -> void:
	# Load data
	%MusicVolume/HSlider.value = Global.music_volume
	%SFXVolume/HSlider.value = Global.sfx_volume


func _on_back_pressed() -> void:
	# Save changes and go back to menu
	var main_menu: String = "res://Menus/main_menu.tscn"
	var config: ConfigFile = ConfigFile.new()
	config.set_value("Settings", "music_volume", Global.music_volume)
	config.set_value("Settings", "sfx_volume", Global.sfx_volume)
	config.set_value("Settings", "joystick_control", Global.joystick_control)
	config.set_value("Settings", "dual_joysticks", Global.dual_joysticks)
	config.save("user://settings.cfg")
	Global.menu_music_progress = music.get_playback_position()
	get_tree().change_scene_to_file(main_menu)


func _process(_delta: float) -> void:
	# Set audio bus volumes
	Global.music_volume = %MusicVolume/HSlider.value
	Global.sfx_volume = %SFXVolume/HSlider.value
	
	%Gameplay/ControlMode.text = CONTROL_MODE_TEXTS[int(Global.joystick_control)]
	%Gameplay/JoystickMode.text = JOYSTICK_MODE_TEXTS[int(Global.dual_joysticks)]
	
	# Button selection
	if Global.joystick_control:
		if Input.is_action_just_pressed("down1") or Input.is_action_just_pressed("down2"):
			current_selection += 1
			if current_selection > SettingsButtons.BACK:
				current_selection = SettingsButtons.MODE
		if Input.is_action_just_pressed("up1") or Input.is_action_just_pressed("up2"):
			current_selection -= 1
			if current_selection < SettingsButtons.MODE:
				current_selection = SettingsButtons.BACK
		
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
	
	# Display current audio levels
	%MusicVolume/Value.text = str(int(Global.music_volume))
	%SFXVolume/Value.text = str(int(Global.sfx_volume))


# Switch control modes
func _on_control_mode_pressed() -> void:
	Global.joystick_control = not Global.joystick_control


# Switch joystuck setups
func _on_joystick_mode_pressed() -> void:
	Global.dual_joysticks = not Global.dual_joysticks
