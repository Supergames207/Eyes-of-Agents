class_name UpgradeTree extends Sprite3D


@export var bounds := Rect2i()
@export var target : MeshInstance3D
@export var target_offset := Vector3.ZERO

var panning_sensivity := Vector2(1, 1)


# func _gui_input(e : InputEvent):
# 	if e is InputEventMouseMotion:
# 		var event : InputEventMouseMotion = e

# 		var panning := event.screen_relative

# 		position += panning

# 		position = position.clamp(bounds.position, bounds.end)
	

# The size of the quad mesh itself.
var quad_mesh_size : Vector2
# Used for checking if the mouse is inside the Area
var is_mouse_inside := false
# Used for checking if the mouse was pressed inside the Area
var is_mouse_held := false
# The last non-empty mouse position. Used when dragging outside of the box.
var mouse_pos3D : Vector3
# The last processed input touch/mouse event. To calculate relative movement.
var last_mouse_pos2D : Vector2

var plane_mouse_pos : Vector2

@export var node_viewport : SubViewport
@export  var node_quad : MeshInstance3D


func _ready() -> void:
	quad_mesh_size = Vector2(node_quad.mesh.size.x, node_quad.mesh.size.y)
	# If the material is NOT set to use billboard settings, then avoid running billboard specific code
	# if node_quad.material_override.params_billboard_mode == 0:
	# set_process(false)
	
	# if OS.get_current_video_driver() == OS.VIDEO_DRIVER_GLES2:
	# 	# Required to prevent the texture from being too dark when using GLES2.
	# 	# This should be left to `true` in GLES3 to prevent the texture from looking
	# 	# washed out there.
	# 	node_quad.material_override.flags_albedo_tex_force_srgb = false


func ray_intersects_quad(origin : Vector3, normal : Vector3, a : Vector3, b : Vector3, c : Vector3, d : Vector3) -> Vector3:
	var first_trig : Variant = Geometry3D.ray_intersects_triangle(origin, normal, a, b, c)
	
	var second_trig : Variant = Geometry3D.ray_intersects_triangle(origin, normal, b, c, d)

	if first_trig:
		return first_trig
	
	elif second_trig:
		return second_trig

	return Vector3.INF


func global_to_plane(pos : Vector3) -> Vector2:
	pos -= node_quad.global_position

	var result := Vector2.ZERO
	result.x = mouse_pos3D.dot(node_quad.global_basis.x)
	result.y = mouse_pos3D.dot(node_quad.global_basis.y)

	return result

func _process(_delta : float):
	# NOTE: Remove this function if you don't plan on using billboard settings.
	# rotate_area_to_billboard()

	var cam := GlobalVariables.player.camera

	is_mouse_inside = false

	
	var origin := cam.project_ray_origin(GlobalVariables.main_viewport.get_mouse_position())
	var normal := cam.project_ray_normal(GlobalVariables.main_viewport.get_mouse_position())
	
	var size_3d := Vector3(quad_mesh_size.x, quad_mesh_size.y, 0) / 2.0
	var a := node_quad.global_position + (node_quad.global_basis * size_3d * Vector3(-1, -1, 0))
	var b := node_quad.global_position + node_quad.global_basis * size_3d * Vector3(-1, 1, 0)
	var c := node_quad.global_position + node_quad.global_basis * size_3d * Vector3(1, -1, 0)
	var d := node_quad.global_position + node_quad.global_basis * size_3d * Vector3(1, 1, 0)
 
	var quad_intersection := ray_intersects_quad(origin, normal, a, b, c, d)

	if quad_intersection.is_finite():
		is_mouse_inside = true
		mouse_pos3D = quad_intersection
		plane_mouse_pos = global_to_plane(quad_intersection)

		

	# prints(origin, normal, is_mouse_inside, a, b, c, d, is_mouse_inside)
	

func _input(event : InputEvent) -> void:
	# Check if the event is a non-mouse/non-touch event
	var is_mouse_event := event is InputEventMouseButton or event is InputEventMouseMotion
	prints("INPUT", event)
	# If the event is a mouse/touch event and/or the mouse is either held or inside the area, then
	# we need to do some additional processing in the handle_mouse function before passing the event to the viewport.
	# If the event is not a mouse/touch event, then we can just pass the event directly to the viewport.
	if is_mouse_event and (is_mouse_inside or is_mouse_held):
		handle_mouse(event)
	elif not is_mouse_event:
		node_viewport.input(event)


# Handle mouse events inside Area. (Area.input_event had many issues with dragging)
func handle_mouse(event : InputEvent) -> void:
	# Detect mouse being held to mantain event while outside of bounds. Avoid orphan clicks
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		is_mouse_held = event.pressed
	

	# convert the relative event position from 3D to 2D
	var mouse_pos2D := plane_mouse_pos

	# Right now the event position's range is the following: (-quad_size/2) -> (quad_size/2)
	# We need to convert it into the following range: 0 -> quad_size
	# mouse_pos2D.x += quad_mesh_size.x / 2
	# mouse_pos2D.y += quad_mesh_size.y / 2
	# Then we need to convert it into the following range: 0 -> 1
	mouse_pos2D.x = mouse_pos2D.x / quad_mesh_size.x
	mouse_pos2D.y = mouse_pos2D.y / quad_mesh_size.y

	# Finally, we convert the position to the following range: 0 -> viewport.size
	mouse_pos2D.x = mouse_pos2D.x * node_viewport.size.x
	mouse_pos2D.y = mouse_pos2D.y * node_viewport.size.y
	# We need to do these conversions so the event's position is in the viewport's coordinate system.

	# Set the event's position and global position.
	event.position = mouse_pos2D
	event.global_position = mouse_pos2D

	prints("MOUSE POS", mouse_pos2D)
	# If the event is a mouse motion event...
	if event is InputEventMouseMotion:
		# If there is not a stored previous position, then we'll assume there is no relative motion.
		if last_mouse_pos2D == null:
			event.relative = Vector2(0, 0)
		# If there is a stored previous position, then we'll calculate the relative position by subtracting
		# the previous position from the new position. This will give us the distance the event traveled from prev_pos
		else:
			event.relative = mouse_pos2D - last_mouse_pos2D
	# Update last_mouse_pos2D with the position we just calculated.
	last_mouse_pos2D = mouse_pos2D

	# Finally, send the processed input event to the viewport.
	node_viewport.push_input(event, true)
	

# func find_further_distance_to(origin):
# 	# Find edges of collision and change to global positions
# 	var edges = []
# 	edges.append(node_area.to_global(Vector3(quad_mesh_size.x / 2, quad_mesh_size.y / 2, 0)))
# 	edges.append(node_area.to_global(Vector3(quad_mesh_size.x / 2, -quad_mesh_size.y / 2, 0)))
# 	edges.append(node_area.to_global(Vector3(-quad_mesh_size.x / 2, quad_mesh_size.y / 2, 0)))
# 	edges.append(node_area.to_global(Vector3(-quad_mesh_size.x / 2, -quad_mesh_size.y / 2, 0)))

# 	# Get the furthest distance between the camera and collision to avoid raycasting too far or too short
# 	var far_dist = 0
# 	var temp_dist
# 	for edge in edges:
# 		temp_dist = origin.distance_to(edge)
# 		if temp_dist > far_dist:
# 			far_dist = temp_dist

# 	return far_dist


# func rotate_area_to_billboard():
# 	var billboard_mode = node_quad.material_override.params_billboard_mode

# 	# Try to match the area with the material's billboard setting, if enabled
# 	if billboard_mode > 0:
# 		# Get the camera
# 		var camera = get_viewport().get_camera_3d()
# 		# Look in the same direction as the camera
# 		var look = camera.to_global(Vector3(0, 0, -100)) - camera.global_transform.origin
# 		look = node_area.position + look

# 		# Y-Billboard: Lock Y rotation, but gives bad results if the camera is tilted.
# 		if billboard_mode == 2:
# 			look = Vector3(look.x, 0, look.z)

# 		node_area.look_at(look, Vector3.UP)

# 		# Rotate in the Z axis to compensate camera tilt
# 		node_area.rotate_object_local(Vector3.BACK, camera.rotation.z)
