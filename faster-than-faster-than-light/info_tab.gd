extends PanelContainer


@onready var ui: Control = get_node("/root/Space/CanvasLayer/UserInterface")
@onready var id: int = get_meta("id")

const HOVER_COLOUR: Color = Color8(160, 100, 100)
const NORMAL_COLOUR: Color = Color8(160, 0, 0)


func _process(_delta: float) -> void:
	if ui.info_showing == id:
		get_theme_stylebox("panel").draw_center = true
	else:
		get_theme_stylebox("panel").draw_center = false


func _on_button_pressed() -> void:
	ui.info_showing = id
	ui.get_node("PressSFX").play()


func _on_button_mouse_entered() -> void:
	get_theme_stylebox("panel").border_color = HOVER_COLOUR
	ui.get_node("HoverSFX").play()


func _on_button_mouse_exited() -> void:
	get_theme_stylebox("panel").border_color = NORMAL_COLOUR
