class_name Player extends Node3D

var camera : CameraHandler

func _ready():
	camera = get_node("Camera3D")
	GlobalVariables.player = self
	

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("UnlockMouse"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_CONFINED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	