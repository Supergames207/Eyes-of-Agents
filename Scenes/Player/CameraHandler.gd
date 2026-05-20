class_name CameraHandler extends Camera3D

@export_range(0, 180) var max_angle := 10.0
@export var weight := .1
@export var pitch_range := Vector2(-85, 85)



func _process(delta: float) -> void:
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var screen_size := get_viewport().get_visible_rect().size
	var dist_center: Vector2 = Vector2(
		(mouse_pos.x - screen_size.x / 2.0) / (screen_size.x / 2.0),
		(mouse_pos.y - screen_size.y / 2.0) / (screen_size.y / 2.0))
	
	var angle_to_apply: Vector2 = max_angle * dist_center
	rotation_degrees.x = lerp(rotation_degrees.x, -angle_to_apply.y, weight)
	rotation_degrees.y = lerp(rotation_degrees.y, -angle_to_apply.x, weight)
