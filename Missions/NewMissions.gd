extends Node

func _new_missions(loc_container: Control) -> void:
	for l in loc_container.get_children():
		var rng := RandomNumberGenerator.new()
		rng.randomize()
		var val := rng.randfn(5, 1.5)
		var result := int(clamp(val, 0, 10))
		
		var random_loc: String = RandomStrings.random_locations.pick_random()
		
		var random_obj: String = RandomStrings.random_objectives.pick_random()
		
		l.danger = result
		l.location = random_loc
		l.objective = random_obj
