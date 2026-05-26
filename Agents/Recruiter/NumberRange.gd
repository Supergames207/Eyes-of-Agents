class_name NumberRange extends Resource

var start : float
var end : float

var step : float

func _init(i : float, f : float, s : float) -> void:
	start = i
	end = f
	step = s

func make_within_range(value : float) -> float:
	return clampf( snappedf(value, step), start, end)
