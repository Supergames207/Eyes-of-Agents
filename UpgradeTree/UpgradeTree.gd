@tool
extends Control

const panning_sensivity := Vector2(1, 1)
const zoom_senvivity := 1

const zoom_bound := Vector2(-1, 1)
const scale_bound := Vector2(1, 10)

@export_tool_button("Convert Editor Mess To Resource Tree") var convertor := convert_nodes_to_resource_tree


func _ready() -> void:
	set_process(not Engine.is_editor_hint())


func _gui_input(e : InputEvent) -> void:
	prints("GINPUT", Input.get_axis("Zoom Out", "Zoom In"))
	if e is InputEventMouseMotion:
		var event : InputEventMouseMotion = e

		if Input.is_action_pressed("Click"):
			prints("PANNING?")
			global_position += event.screen_relative * panning_sensivity
			accept_event()

	elif Input.is_action_pressed("Zoom Out") or Input.is_action_pressed("Zoom In"): #ZOOM
		var old_pos := get_local_mouse_position()
		scale += Vector2.ONE * clampf(Input.get_axis("Zoom Out", "Zoom In"), zoom_bound.x, zoom_bound.y) * zoom_senvivity
		scale = scale.clampf(scale_bound.x, scale_bound.y)
		
		global_position = -old_pos * scale + get_global_mouse_position()

#TODO Both of the conversion functions
func convert_nodes_to_resource_tree() -> void:
	pass

func convert_resource_tree_to_nodes() -> void:
	pass