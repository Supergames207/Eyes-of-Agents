class_name MainScene extends Node


func _ready() -> void:
	GlobalVariables.main_scene = self
	GlobalVariables.main_viewport = get_node("CameraViewportContainer/SubViewport")
	GlobalVariables.global_perk_holder = get_node("PerkHolder")

	GlobalVariables.player.camera.make_current()

	GlobalVariables.game_loaded.emit()