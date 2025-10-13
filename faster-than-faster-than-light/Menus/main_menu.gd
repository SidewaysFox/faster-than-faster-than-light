extends Control


var current_menu_selection: int = 0

const BUTTON_COLOUR_NORMAL: Color = Color(1.0, 1.0, 1.0)
const BUTTON_COLOUR_HOVER: Color = Color(0.0, 0.749, 1.0)


func _ready() -> void:
	%Version/Label.text = "VERSION: " + ProjectSettings.get_setting("application/config/version")


func _process(_delta: float) -> void:
	if Global.joystick_control:
		if Input.is_action_just_pressed("down1") or Input.is_action_just_pressed("down2"):
			current_menu_selection += 1
			if current_menu_selection >= %Buttons.get_child_count():
				current_menu_selection = 0
		if Input.is_action_just_pressed("up1") or Input.is_action_just_pressed("up2"):
			current_menu_selection -= 1
			if current_menu_selection < 0:
				current_menu_selection = %Buttons.get_child_count() - 1
		
		for button in %Buttons.get_children():
			if button.get_index() == current_menu_selection:
				button.get_child(0).add_theme_color_override("font_color", BUTTON_COLOUR_HOVER)
				if Input.is_action_just_pressed("1") or Input.is_action_just_pressed("A"):
					button.get_child(0).emit_signal("pressed")
			else:
				button.get_child(0).add_theme_color_override("font_color", BUTTON_COLOUR_NORMAL)


func _on_new_game_pressed(tutorial: bool = false) -> void:
	Global.new_game(tutorial)


func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://Menus/settings.tscn")


func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://Menus/credits.tscn")


func _on_quit_pressed() -> void:
	var config: ConfigFile = ConfigFile.new()
	config.set_value("Settings", "music_volume", Global.music_volume)
	config.set_value("Settings", "sfx_volume", Global.sfx_volume)
	config.set_value("Settings", "joystick_control", Global.joystick_control)
	config.set_value("Settings", "dual_joysticks", Global.dual_joysticks)
	config.save("user://scores.cfg")
	get_tree().quit()


func _on_continue_pressed() -> void:
	Global.continuing = true
	Global.new_game()
