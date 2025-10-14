extends Control


const BUTTON_COLOUR_HOVER: Color = Color(0.0, 0.749, 1.0)


func _process(_delta: float) -> void:
	if Global.joystick_control:
		%Options/Option1.add_theme_color_override("font_color", BUTTON_COLOUR_HOVER)
		if Input.is_action_just_pressed("1") or Input.is_action_just_pressed("A"):
			_on_back_pressed()


func _on_back_pressed() -> void:
	var main_menu: String = "res://Menus/main_menu.tscn"
	get_tree().change_scene_to_file(main_menu)
