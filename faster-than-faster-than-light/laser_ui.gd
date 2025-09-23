extends Control


func _process(_delta):
	var pos_3d: Vector3 = get_parent().target_pos
	var cam := get_viewport().get_camera_3d()
	var pos_2d := cam.unproject_position(pos_3d)
	global_position = pos_2d
