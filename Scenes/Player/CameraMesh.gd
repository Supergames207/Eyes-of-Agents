class_name CameraTarget extends Marker3D

@onready var main_mother := self.get_parent()
@onready var player: Node3D = GlobalVariables.player

var mouse_over_mother := false

func _ready() -> void:
	print(main_mother.name)

func _physics_process(_delta: float) -> void:
	_check_mouse_over_parent()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Click") and mouse_over_mother == true:
		player.position = lerp(player.position, main_mother.position, 0.1)
		player.rotation = lerp(player.rotation, main_mother.rotation, 0.1)

func _check_mouse_over_parent() -> void:
	var camera: Camera3D = player.get_node("Camera3D")
	if not camera: return
	var mouse_pos := get_viewport().get_mouse_position()
	if not mouse_pos: return
	
	var ray_origin := camera.project_ray_origin(mouse_pos)
	var ray_end := ray_origin + camera.project_ray_normal(mouse_pos) * 1000.0
	
	var space_state := get_world_3d().direct_space_state
	
	var query := PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	
	var result := space_state.intersect_ray(query)
	
	if result.collider.get_parent() == main_mother:
		if not mouse_over_mother:
			mouse_over_mother = true
			_add_outline(main_mother, true)
	else:
		if mouse_over_mother:
			mouse_over_mother = false
			_add_outline(main_mother, false)

func _add_outline(target: MeshInstance3D, enabled: bool) -> void:
	var existence := target.get_node_or_null("Outline")
	
	if enabled == true and not existence:
		var outline := MeshInstance3D.new()
		outline.mesh = target.mesh
		outline.name = "Outline"
		
		var material := StandardMaterial3D.new()
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.albedo_color = Color.WHITE
		material.cull_mode = BaseMaterial3D.CULL_FRONT
		material.grow = true
		material.grow_amount = 0.02
		material.no_depth_test = false
		
		outline.material_override = material
		target.add_child(outline)
	else: if enabled == false and existence:
		existence.queue_free()
