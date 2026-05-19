extends Camera3D

@export_range(0, 180) var max_angle = 10.0

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse_pos = event.position
		var screen_size := get_viewport().get_visible_rect().size
		var dist_center: Vector2 = Vector2(
			(mouse_pos.x - screen_size.x / 2.0) / (screen_size.x / 2.0),
			(mouse_pos.y - screen_size.y / 2.0) / (screen_size.y / 2.0))
		
		var angle_to_apply: Vector2 = max_angle * dist_center
		rotation_degrees.x = -angle_to_apply.y
		rotation_degrees.y = -angle_to_apply.x
		
