extends Control


const OFFSET: Vector2 = Vector2.ONE * 50.0


func _process(_delta):
	var pos_3d: Vector3 = get_parent().global_position
	var cam := get_viewport().get_camera_3d()
	var pos_2d := cam.unproject_position(pos_3d)
	global_position = pos_2d - OFFSET
