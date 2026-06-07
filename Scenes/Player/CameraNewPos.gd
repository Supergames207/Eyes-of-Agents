extends  Node3D

@onready var player: Node3D = GlobalVariables.player

var moving: bool = false

var target_pos : Vector3
var target_basis : Basis

var camera_node : Node3D

func _process(delta: float) -> void:
	if moving and camera_node:
		camera_node.global_position = lerp(camera_node.global_position, target_pos, min(1, 10.0 * delta))
		
		camera_node.global_basis = camera_node.global_basis.slerp(target_basis, min(1, 10 * delta))

		if camera_node.global_position.distance_to(target_pos) < 0.01 and camera_node.global_basis.z.angle_to(target_basis.z) < 0.01:
			camera_node.global_position = target_pos
			camera_node.global_basis = target_basis
			moving = false


func _new_pos(marker: Marker3D, camera: Node3D) -> void:
	camera_node = camera
	
	target_pos = marker.global_position
	target_basis = marker.global_basis
	
	moving = true
