extends Control

@onready var player: Node3D = GlobalVariables.player
var left_button: Button
var right_button: Button
var camera_points: Node3D
var points_array: Array
var count: int = 0
var current: int = 0
var new_point: Marker3D

func _ready() -> void:
	left_button = $LeftButton
	right_button = $RightButton
	
	left_button.pressed.connect(_on_button_press.bind(0))
	right_button.pressed.connect(_on_button_press.bind(1))
	
	camera_points = $"../../CameraPoints"
	if not camera_points:
		print("No Parent No Script :(")
		return
	
	# array for all children on the scripts parent
	for p in camera_points.get_children():
		if not p == self:
			points_array.append(count)
			count += 1

func _process(_delta: float) -> void:
	# buttons visibility (tenho que adicionar lerp depois ou tween)
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var screen_width: float = get_viewport().get_visible_rect().size.x
	left_button.visible = mouse_pos.x < screen_width * 0.075
	right_button.visible = mouse_pos.x > screen_width * 0.925

func _on_button_press(side: int) -> void:
	# Get current Number
	for p in camera_points.get_children():
		if not p == self and p.global_rotation.y == player.global_rotation.y:
			current = _get_number_from_string(p.name)
	
	if side == 0: #left
		current = (current + 1 + points_array.size()) % points_array.size()
		new_point = camera_points.get_node(_get_string_from_number(current, camera_points))
		CameraNewPos._new_pos(new_point, player)
	
	else: if side == 1: #right
		current = (current - 1 + points_array.size()) % points_array.size()
		new_point = camera_points.get_node(_get_string_from_number(current, camera_points))
		CameraNewPos._new_pos(new_point, player)

func _get_number_from_string(string: String) -> int:
	var regex := RegEx.new()
	regex.compile("\\d+")
	var all_numbers_found := regex.search_all(string)
	for number in all_numbers_found:
		var number_found := int(number.get_string())
		return number_found
	return -1

func _get_string_from_number(number: int, group:Node3D) -> String:
	for c in group.get_children():
		if _get_number_from_string(c.name) == number:
			return c.name
	return ""
