class_name NumberRange extends Resource

@export var start : float
@export var end : float

@export var step : float

func _init(i : float = -INF, f : float = -INF, s : float = -INF) -> void:
	if i != -INF:
		start = i
	if f != -INF:
		end = f
	if s != -INF:
		step = s

func make_within_range(value : float) -> float:
	return clampf( snappedf(value, step), start, end)
