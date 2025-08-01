extends Control


var unpause_ready: bool = false


func _process(delta: float) -> void:
	print(unpause_ready)
	if Input.is_action_just_pressed("pause") and get_tree().paused and unpause_ready:
		print("unpause")
		_on_continue_pressed()
	if Input.is_action_just_pressed("debug quit"):
		get_tree().quit()


func _on_continue_pressed() -> void:
	hide()
	unpause_ready = false
	get_tree().paused = false


func _on_settings_pressed() -> void:
	pass # Replace with function body.


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_unpause_timer_timeout() -> void:
	unpause_ready = true
