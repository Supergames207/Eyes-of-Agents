extends Resource

var perks : Dictionary[String, Perk] = {}


enum UpdateType{
	Add,
	BaseMultiply,
	Multiply,
}

func update_perk(perk_name : StringName, change : float, type : UpdateType) -> Error:
	if not perk_name in perks:
		push_error("Couldn't find string", perk_name, " in perks dictionary")
		return ERR_DOES_NOT_EXIST
	
	var perk := perks[perk_name]

	match type:
		UpdateType.Add:
			perk.change_apparent_value(perk.apparent_value + change)
		
		UpdateType.BaseMultiply:
			perk.change_apparent_value(perk.apparent_value + perk.base_value * change)
		
		UpdateType.Multiply:
			perk.multiplier += change
	
	return OK

	
