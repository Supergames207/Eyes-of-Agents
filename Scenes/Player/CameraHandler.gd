class_name CameraHandler extends Camera3D

@export var pitch_range := Vector2(-85, 85)

var sensivity := Vector2.ONE * 0.01

func _unhandled_input(e: InputEvent) -> void:
	if e is InputEventMouseMotion:
		var event : InputEventMouseMotion = e

		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			rotation_degrees.y -= event.screen_relative.x
			rotation_degrees.x -= event.screen_relative.y

			rotation_degrees.x = clampf(rotation_degrees.x, pitch_range.x, pitch_range.y)
		
	