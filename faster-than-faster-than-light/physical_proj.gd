extends Area3D


@onready var main: Node = get_node("/root/Space")
@export var missed_ui: PackedScene
var starting_position: Vector3
var target: Node
var target_pos: Vector3
var movement_target: Vector3
var damage: int
var missed: bool = false

const SPEED: float = 400.0


func _ready() -> void:
	print("FIRED")
	global_position = starting_position
	target_pos = target.global_position
	look_at(target_pos)
	movement_target = $Point.global_position


func _process(delta: float) -> void:
	global_position = global_position.move_toward(movement_target, SPEED * delta)
	if global_position.distance_to(target_pos) < 8.0 and target != null and not missed:
		if target.agility < randf() * 0.75:
			print("HIT")
			target.hull -= damage
			queue_free()
		else:
			print("MISSED")
			missed = true
			$Control.add_child(missed_ui.instantiate())


func _on_auto_free_timeout() -> void:
	queue_free()
