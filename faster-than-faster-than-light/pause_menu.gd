extends Control


var unpause_ready: bool = false


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause") and get_tree().paused and unpause_ready:
		_on_continue_pressed()
	if Input.is_action_just_pressed("debug quit"):
		get_tree().quit()
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


func _on_continue_pressed() -> void:
	hide()
	$Main.show()
	$Settings.hide()
	unpause_ready = false
	get_tree().paused = false


func _on_settings_pressed() -> void:
	$Main.hide()
	$Settings.show()


func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Menus/main_menu.tscn")


func _on_unpause_timer_timeout() -> void:
	unpause_ready = true


func _on_back_pressed() -> void:
	$Settings.hide()
	$Main.show()


func _on_control_mode_pressed() -> void:
	Global.joystick_control = not Global.joystick_control


func _on_joystick_mode_pressed() -> void:
	Global.dual_joysticks = not Global.dual_joysticks
