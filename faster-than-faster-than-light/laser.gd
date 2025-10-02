extends Area3D


@onready var main: Node = get_node("/root/Space")
@export var missed_ui: PackedScene
var starting_position: Vector3
var target: Node
var target_pos: Vector3
var movement_target: Vector3
var damage: int
var missed: bool = false

const SPEED: float = 250.0
const CRIT_BONUS: int = 2


func _ready() -> void:
	global_position = starting_position
	target_pos = target.global_position
	look_at(target_pos)
	movement_target = $Point.global_position


func _process(delta: float) -> void:
	global_position = global_position.move_toward(movement_target, SPEED * delta)
	if global_position.distance_to(target_pos) < 5.0 and target != null and not missed:
		if target.team == 1:
			for ship in main.get_node("FriendlyShips").get_children():
				if ship.type == 2 and ship.shield_layers > 0:
					ship.shield_layers -= 1
					_blocked()
					break
		else:
			for ship in main.get_node("HostileShips").get_children():
				if ship.type == 2 and ship.shield_layers > 0:
					ship.shield_layers -= 1
					_blocked()
					break
		if target.agility < randf() and not is_queued_for_deletion():
			if Global.crit_chance > randf():
				target.hull -= damage + CRIT_BONUS
				_crit()
			else:
				target.hull -= damage
			queue_free()
		else:
			missed = true
			$Control.add_child(missed_ui.instantiate())


func _blocked() -> void:
	var new_missed: Node = missed_ui.instantiate()
	new_missed.get_child(0).text = "BLOCKED"
	new_missed.global_position = $Control.global_position
	main.add_child(new_missed)
	queue_free()


func _crit() -> void:
	var new_crit: Node = missed_ui.instantiate()
	new_crit.get_child(0).text = "CRITICAL HIT"
	new_crit.global_position = $Control.global_position
	main.add_child(new_crit)


func _on_auto_free_timeout() -> void:
	queue_free()
