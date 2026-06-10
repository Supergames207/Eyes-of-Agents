class_name Player extends Node3D

const agents_file_path = "user://Player/Agents"

var camera : CameraHandler
var agents : AgentArray

var money : int
var waiting_money : int
var adjacent_money_losses : int


func _ready() -> void:
	camera = get_node("Camera3D")
	camera.make_current()
	
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

func end_game() -> void:
	if money > 0:
		return
	
	push_error("Player is just too bad!")

	var streamer := AudioManager.play("res://Sounds/household_door_knocks_x4_internal_wooden_slightly_angry.mp3")

	streamer.finished.connect(func() -> void:
		AudioManager.play("res://Sounds/master_of_dreams_creaking_doors_4_353.mp3")
		GlobalVariables.main_scene.get_node("EndGame").close_eyes() 
		,CONNECT_ONE_SHOT)

	
	

func _exit_tree() -> void:
	ResourceSaver.save(agents, agents_file_path)
