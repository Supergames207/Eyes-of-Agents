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
	GlobalVariables.day_ended.connect(day_ended)

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("UnlockMouse"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func day_ended() -> void:
	waiting_money = roundi(waiting_money * GlobalPerkHolder.get_perk_value("MoneyMultiplier"))
	
	var paycheck := roundi(GlobalPerkHolder.get_perk_value("DaySalary"))

	money += waiting_money + paycheck - agents.overall_cost - adjacent_money_losses
	waiting_money = 0
	adjacent_money_losses = 0

	if money < 0:
		push_error("Player is just too bad!")
		get_tree().quit()


func _exit_tree() -> void:
	ResourceSaver.save(agents, agents_file_path)
