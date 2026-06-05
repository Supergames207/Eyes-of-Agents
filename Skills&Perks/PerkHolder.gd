@tool
class_name PerkHolder extends Node

const editor_save_path := "res://Skills&Perks/DefaultPerks.tres"
const save_path := "user://Perks.tres"

@export_tool_button("Save Perks Lookup") var saver := save_lookup
@export_tool_button("Load Last Perks Lookup") var loader := load_lookup
@export var perks_lookup : PerksLookup


enum UpdateType{
	Add,
	BaseMultiply,
	Multiply,
}

func _ready() -> void:
	load_lookup()
	

func update_perk(perk_name : StringName, change : float, type : UpdateType) -> Error:
	if not perk_name in perks_lookup.perks:
		push_error("Couldn't find string", perk_name, " in perks lookup dictionary")
		return ERR_DOES_NOT_EXIST
	
	var perk := perks_lookup.perks[perk_name]

	match type:
		UpdateType.Add:
			perk.change_apparent_value(perk.apparent_value + change)
		
		UpdateType.BaseMultiply:
			perk.change_apparent_value(perk.apparent_value + perk.base_value * change)
		
		UpdateType.Multiply:
			perk.multiplier += change
	
	return OK

func add_perk(perk_name : StringName, base_value : float, value_range : NumberRange, multiplier : float = 1.0) -> void:
	var new_perk := Perk.new()
	new_perk.base_value = base_value
	new_perk.apparent_value = new_perk.base_value

	new_perk.value_range = value_range
	new_perk.multiplier = multiplier
	
	perks_lookup.perks[perk_name] = new_perk

func get_perk(perk_name : StringName) -> Perk:
	if not perk_name in perks_lookup.perks:
		return
	
	return perks_lookup.perks[perk_name]

func get_perk_value(perk_name : StringName) -> float:
	if not perk_name in perks_lookup.perks:
		return 0
	
	return perks_lookup.perks[perk_name].get_value()


func save_lookup() -> void:
	if Engine.is_editor_hint():
		ResourceSaver.save(perks_lookup, editor_save_path)
	else:
		ResourceSaver.save(perks_lookup, save_path)

func load_lookup() -> void:
	if Engine.is_editor_hint():
		perks_lookup = ResourceLoader.load(editor_save_path)
		return
	
	if ResourceLoader.exists(save_path):
		perks_lookup = ResourceLoader.load(save_path)
	else:
		perks_lookup = PerksLookup.new()

func _exit_tree() -> void:
	save_lookup()
