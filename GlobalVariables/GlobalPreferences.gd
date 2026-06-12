@tool
class_name PreferenceNode extends Node

const editor_save_path := "res://Preferences.tres"

@export var preferences : Preferences 

@export_tool_button("Save Perks Lookup") var saver := save_lookup
@export_tool_button("Load Last Perks Lookup") var loader := load_lookup


func save_lookup() -> void:
	ResourceSaver.save(preferences, editor_save_path)

func load_lookup() -> void:
	preferences = ResourceLoader.load(editor_save_path)
		
