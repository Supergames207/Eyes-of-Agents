class_name Perk extends Resource

@export var base_value : float
@export var value_range : NumberRange
@export var apparent_value : float
@export var multiplier : float = 1.0


	
func get_value() -> float:
	return value_range.make_within_range(apparent_value * multiplier)

func change_apparent_value(new : float) -> void:
	apparent_value = value_range.make_within_range(new)
	 
