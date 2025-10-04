extends Control


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Menus/main_menu.tscn")


func _process(_delta: float) -> void:
	%MusicVolume/Value.text = str(int(%MusicVolume/HSlider.value))
	%SFXVolume/Value.text = str(int(%SFXVolume/HSlider.value))
	Global.music_volume = %MusicVolume/HSlider.value
	Global.sfx_volume = %SFXVolume/HSlider.value
	if Global.joystick_control:
		%Gameplay/ControlMode.text = "CONTROL MODE: ARCADE"
	else:
		%Gameplay/ControlMode.text = "CONTROL MODE: KEYBOARD/MOUSE"
	if Global.dual_joysticks:
		%Gameplay/JoystickMode.text = "JOYSTICK MODE: DUAL"
	else:
		%Gameplay/JoystickMode.text = "JOYSTICK MODE: SINGLE"


func _on_control_mode_pressed() -> void:
	Global.joystick_control = not Global.joystick_control


func _on_joystick_mode_pressed() -> void:
	Global.dual_joysticks = not Global.dual_joysticks
