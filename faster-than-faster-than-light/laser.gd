extends Area3D


const SPEED: float = 250.0
var starting_position: Vector3
var target: Node
var target_pos: Vector3
var damage: int


func _ready() -> void:
	global_position = starting_position
	target_pos = target.global_position
	look_at(target_pos)


func _process(delta: float) -> void:
	global_position = global_position.move_toward(target_pos, SPEED * delta)
	if global_position.is_equal_approx(target_pos) and target != null:
		target.hull -= damage
		queue_free()


func _on_auto_free_timeout() -> void:
	queue_free()
