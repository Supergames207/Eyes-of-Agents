extends  Node3D

@onready var player: Node3D = GlobalVariables.player

var moving: bool = false
var target_pos: Vector3
var target_rot: Vector3
var camera_node: Node3D

func _process(delta: float) -> void:
	if moving and camera_node:
		camera_node.global_position = lerp(camera_node.global_position, target_pos, 10.0 * delta)
		camera_node.global_rotation = lerp(camera_node.global_rotation, target_rot, 10.0 * delta)
		if camera_node.global_position.distance_to(target_pos) < 0.01 and camera_node.global_rotation.distance_to(target_rot) < 0.01:
			camera_node.global_position = target_pos
			camera_node.global_rotation = target_rot
			moving = false


func _new_pos(marker: Variant, camera: Node3D) -> void:
	camera_node = camera
	if marker is Marker3D:
		target_pos = marker.global_position
		target_rot = marker.global_rotation
	else: if marker is Vector3:
		target_pos = marker
		target_rot = marker.global_rotation
	moving = true
