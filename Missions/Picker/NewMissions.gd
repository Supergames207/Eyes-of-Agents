extends Node

func _new_missions(loc_container: VBoxContainer) -> void:
	for l in loc_container.get_children():
		if not l is LocationButton: 
			continue
		var rng := RandomNumberGenerator.new()
		rng.randomize()
		var val := rng.randfn(40, 50)
		var result := int(clamp(val, 3, 90))
		
		var random_loc: String = RandomStrings.random_locations.pick_random()
		
		var random_obj: String = RandomStrings.random_objectives.pick_random()
		
		l.danger = result
		l.location = random_loc
		l.objective = random_obj
