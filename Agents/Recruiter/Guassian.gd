class_name GaussianData extends Resource

@export var mean := 0.0
@export var deviation := 1.0

func _init(m : float = 0.0, dev : float = 1.0) -> void:
	mean = m
	deviation = dev


func get_random() -> float:
	return randfn(mean, deviation)
