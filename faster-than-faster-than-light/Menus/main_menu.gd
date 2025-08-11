extends Control


func _on_new_game_pressed() -> void:
	Global.new_game()


func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://Menus/settings.tscn")


func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://Menus/credits.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
