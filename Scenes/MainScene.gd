class_name MainScene extends Node


func _ready():
    GlobalVariables.main_viewport = get_node("CameraViewportContainer/SubViewport")