class_name Player extends Node3D

const agents_file_path = "user://Player/Agents"

var camera : CameraHandler
var agents : AgentArray

func _ready() -> void:
	camera = get_node("Camera3D")
	GlobalVariables.player = self

	if not DirAccess.dir_exists_absolute("user://Player"):
		DirAccess.make_dir_absolute("user://Player")
	elif DirAccess.dir_exists_absolute(agents_file_path):
		agents = ResourceLoader.load(agents_file_path)

	if not agents:
		agents = AgentArray.new()

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("UnlockMouse"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _exit_tree() -> void:
	ResourceSaver.save(agents, agents_file_path)
