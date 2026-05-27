@tool
extends Control

const panning_sensivity := Vector2(1, 1)
const zoom_senvivity := 1

const zoom_bound := Vector2(0, 1)

@export_tool_button("Convert Editor Mess To Resource Tree") var convertor := convert_nodes_to_resource_tree


func _ready() -> void:
    set_process(not Engine.is_editor_hint())


func _gui_input(e : InputEvent) -> void:
    if e is InputEventMouseMotion:
        var event : InputEventMouseMotion = e

        if Input.is_action_pressed("Click"):
            global_position += event.screen_relative * panning_sensivity
            accept_event()

func _process(delta : float) -> void:
    var zoom := Input.get_axis("Zoom Out", "Zoom In") * zoom_senvivity * delta

    scale *= clamp(zoom, zoom_bound.x, zoom_bound.y)


#TODO Both of the conversion functions
func convert_nodes_to_resource_tree() -> void:
    pass

func convert_resource_tree_to_nodes() -> void:
    pass