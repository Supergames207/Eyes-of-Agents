class_name AutonomousPerk extends Perk

@export var update_period_range := Vector2i.ZERO
@export var update_type : PerkHolder.UpdateType
@export var change_range := Vector2.ZERO

var next_update : int = -1

func _init() -> void:
	prints(GlobalVariables, GlobalVariables.day_ended)

	GlobalVariables.day_ended.emit(autonomous_update)


func autonomous_update() -> void:
	if next_update == -1:
		next_update = GlobalVariables.current_day + randi_range(update_period_range.x, update_period_range.y)
	
	if next_update > GlobalVariables.current_day:
		return
	
	var change := randf_range(change_range.x, change_range.y)
	
	PerkHolder.self_update_perk(self, change, update_type)

	next_update = GlobalVariables.current_day + randi_range(update_period_range.x, update_period_range.y)
	