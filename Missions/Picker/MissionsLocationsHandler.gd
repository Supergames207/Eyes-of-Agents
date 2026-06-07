class_name LocationButton extends Button

@export var danger: float:
	set(value):
		danger = value
		_on_property_changed("danger", value)

@export var location: String:
	set(value):
		location = value
		_on_property_changed("location", value)

@export var objective: String:
	set(value):
		objective = value
		_on_property_changed("objective", value)

func _on_property_changed(_property: String, _value: Variant) -> void:
	text = str(location) + " | RISK: " + str(danger)
