extends Area3D


const SPEED: float = 250.0
var starting_position: Vector3
var target: Node
var target_pos: Vector3
var movement_target: Vector3
var damage: int
var missed: bool = false


func _ready() -> void:
	global_position = starting_position
	target_pos = target.global_position
	look_at(target_pos)
	movement_target = $Point.global_position


func _process(delta: float) -> void:
	global_position = global_position.move_toward(movement_target, SPEED * delta)
	if global_position.distance_to(target_pos) < 5.0 and target != null and not missed:
		if target.agility < randf():
			target.hull -= damage
			queue_free()
		else:
			missed = true


func _on_auto_free_timeout() -> void:
	queue_free()
