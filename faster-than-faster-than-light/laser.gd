extends Area3D


@onready var main: Node3D = get_node("/root/Space")
@export var missed_ui: PackedScene
var starting_position: Vector3
var target: Node3D
var target_pos: Vector3
var movement_target: Vector3
var damage: int
var missed: bool = false

const HIT_DETECT_RANGE: float = 5.0
const SPEED: float = 250.0
const CRIT_BONUS: int = 2
const ACCURACY: float = 1.0
const BLOCKED_TEXT: String = "BLOCKED"
const CRIT_TEXT: String = "CRITICAL HIT"


func _ready() -> void:
	global_position = starting_position
	target_pos = target.global_position
	look_at(target_pos)
	movement_target = $Point.global_position


func _process(delta: float) -> void:
	global_position = global_position.move_toward(movement_target, SPEED * delta)
	if global_position.distance_to(target_pos) < HIT_DETECT_RANGE and target != null and not missed:
		if target.team == Global.Teams.FRIENDLY:
			for ship in main.get_node("FriendlyShips").get_children():
				if ship.type == Global.StarshipTypes.SHIELD and ship.shield_layers > 0:
					ship.shield_layers -= 1
					blocked()
					break
		else:
			for ship in main.get_node("HostileShips").get_children():
				if ship.type == Global.StarshipTypes.SHIELD and ship.shield_layers > 0:
					ship.shield_layers -= 1
					blocked()
					break
		if target.agility < randf() and not is_queued_for_deletion():
			if Global.crit_chance > randf() * ACCURACY:
				target.hull -= damage + CRIT_BONUS
				crit()
			else:
				target.hull -= damage
			queue_free()
		else:
			missed = true
			$Control.add_child(missed_ui.instantiate())


func blocked() -> void:
	var new_missed: Control = missed_ui.instantiate()
	new_missed.get_child(0).text = BLOCKED_TEXT
	new_missed.global_position = $Control.global_position
	main.add_child(new_missed)
	queue_free()


func crit() -> void:
	var new_crit: Control = missed_ui.instantiate()
	new_crit.get_child(0).text = CRIT_TEXT
	new_crit.global_position = $Control.global_position
	main.add_child(new_crit)


func _on_auto_free_timeout() -> void:
	queue_free()
