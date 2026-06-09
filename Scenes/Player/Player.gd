class_name Player extends Node3D

const agents_file_path = "user://Player/Agents"

var camera : CameraHandler
var agents : AgentArray

var money : int
var waiting_money : int
var adjacent_money_losses : int


func _ready() -> void:
	camera = get_node("Camera3D")
	GlobalVariables.player = self

	if not DirAccess.dir_exists_absolute("user://Player"):
		DirAccess.make_dir_absolute("user://Player")
	
	elif DirAccess.dir_exists_absolute(agents_file_path):
		agents = ResourceLoader.load(agents_file_path)

	if not agents:
		agents = AgentArray.new()

	GlobalVariables.game_loaded.emit()

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("UnlockMouse"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _end_game() -> void:
	if money < 0:
		push_error("Player is just too bad!")
		get_tree().quit()


func _exit_tree() -> void:
	ResourceSaver.save(agents, agents_file_path)
