class_name SpriteGUI3D extends Sprite3D


@export var target : MeshInstance3D
@export var node_viewport : SubViewport
@export var quad_mesh_size : Vector3


var is_mouse_inside := false
var is_mouse_held := false

var mouse_pos3D : Vector3
var last_mouse_pos2D : Vector2

var plane_mouse_pos : Vector2

func _ready() -> void:
	quad_mesh_size = Vector3(node_viewport.size.x, node_viewport.size.y, 0) / 100.0# * Vector3(scale.x, scale.y, 0)
	
	texture = node_viewport.get_texture()
	

func ray_intersects_quad(origin : Vector3, normal : Vector3, a : Vector3, b : Vector3, c : Vector3, d : Vector3) -> Vector3:
	var first_trig : Variant = Geometry3D.ray_intersects_triangle(origin, normal, a, b, c)
	
	var second_trig : Variant = Geometry3D.ray_intersects_triangle(origin, normal, b, c, d)

	if first_trig:
		return first_trig
	
	elif second_trig:
		return second_trig

	return Vector3.INF


func global_to_plane(pos : Vector3) -> Vector2:
	pos -= (global_position + (global_basis * quad_mesh_size / 2.0 * Vector3(-1, -1, 0)))

	var result := Vector2.ZERO
	result.x = pos.dot(global_basis.x.normalized())
	result.y = pos.dot(global_basis.y.normalized())

	result.y = quad_mesh_size.y - result.y

	return result 

func _process(_delta : float) -> void:
	if not GlobalVariables.player:
		return
	
	var cam := GlobalVariables.player.camera

	is_mouse_inside = false

	
	var origin := cam.project_ray_origin(GlobalVariables.main_viewport.get_mouse_position())
	var normal := cam.project_ray_normal(GlobalVariables.main_viewport.get_mouse_position())
	
	var size_3d := Vector3(quad_mesh_size.x, quad_mesh_size.y, 0) / 2.0
	var a := global_position + (global_basis * size_3d * Vector3(-1, -1, 0))
	var b := global_position + global_basis * size_3d * Vector3(-1, 1, 0)
	var c := global_position + global_basis * size_3d * Vector3(1, -1, 0)
	var d := global_position + global_basis * size_3d * Vector3(1, 1, 0)
 
	var quad_intersection := ray_intersects_quad(origin, normal, a, b, c, d)

	if quad_intersection.is_finite():
		is_mouse_inside = true
		mouse_pos3D = quad_intersection
		plane_mouse_pos = global_to_plane(quad_intersection)
		
		prints(plane_mouse_pos, is_mouse_inside, get_parent().name)

	
func _input(event : InputEvent) -> void:
	var is_mouse_event := event is InputEventMouseButton or event is InputEventMouseMotion

	if is_mouse_event and (is_mouse_inside or is_mouse_held):
		
		handle_mouse(event)
	elif not is_mouse_event:
		node_viewport.push_input(event)


func handle_mouse(event : InputEvent) -> void:
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		is_mouse_held = event.pressed
	
	var mouse_pos2D := plane_mouse_pos

	mouse_pos2D.x = mouse_pos2D.x / (quad_mesh_size.x * scale.y)
	mouse_pos2D.y = mouse_pos2D.y / (quad_mesh_size.y * scale.y)

	mouse_pos2D.x = mouse_pos2D.x * node_viewport.size.x
	mouse_pos2D.y = mouse_pos2D.y * node_viewport.size.y

	event.position = mouse_pos2D
	event.global_position = mouse_pos2D


	if event is InputEventMouseMotion:
		if last_mouse_pos2D == null:
			event.relative = Vector2(0, 0)
		else:
			event.relative = mouse_pos2D - last_mouse_pos2D
	
	last_mouse_pos2D = mouse_pos2D

	node_viewport.push_input(event, true)
	
