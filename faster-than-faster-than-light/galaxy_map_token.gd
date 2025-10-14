extends Area2D


@onready var ui: Control = find_parent("UserInterface")
var id: int
var rotation_rate: float = randf_range(-45.0, 45.0)

const VISITED_COLOUR: Color = Color.YELLOW


func _process(delta: float) -> void:
	# Spin
	rotation_degrees += rotation_rate * delta
	$Range.scale = Vector2.ONE * (Global.jump_distance / 100.0)


# This is slightly delayed instead of being on the _ready() function so that it
# uses updated data
func _on_timer_timeout() -> void:
	# Check if this token represents the current system
	if id == Global.current_system:
		$ColorRect2.show()
		Global.system_position = position
		$Range.show()
	else:
		$ColorRect2.hide()
		$Range.hide()
		if Global.visited_systems.has(id):
			$ColorRect.color = VISITED_COLOUR
	if Global.galaxy_data[id]["shop presence"]:
		$ShopIndicator.show()
	if id == Global.destination:
		$DestinationIndicator.show()
