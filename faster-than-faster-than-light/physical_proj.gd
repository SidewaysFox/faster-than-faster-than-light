extends Area3D


@onready var main: Node = get_node("/root/Space")
@export var missed_ui: PackedScene
var starting_position: Vector3
var target: Node
var target_pos: Vector3
var movement_target: Vector3
var damage: int
var missed: bool = false

const HIT_DETECT_RANGE: float = 8.0
const SPEED: float = 400.0
const CRIT_BONUS: int = 2
const ACCURACY: float = 0.75
const CRIT_TEXT: String = "CRITICAL HIT"


func _ready() -> void:
	global_position = starting_position
	target_pos = target.global_position
	look_at(target_pos)
	movement_target = $Point.global_position


func _process(delta: float) -> void:
	global_position = global_position.move_toward(movement_target, SPEED * delta)
	if global_position.distance_to(target_pos) < HIT_DETECT_RANGE and target != null and not missed:
		if target.agility < randf() * ACCURACY:
			if Global.crit_chance > randf():
				target.hull -= damage + CRIT_BONUS
			else:
				target.hull -= damage
			queue_free()
		else:
			missed = true
			$Control.add_child(missed_ui.instantiate())


func _crit() -> void:
	var new_crit: Node = missed_ui.instantiate()
	new_crit.get_child(0).text = CRIT_TEXT
	new_crit.global_position = $Control.global_position
	main.add_child(new_crit)


func _on_auto_free_timeout() -> void:
	queue_free()
