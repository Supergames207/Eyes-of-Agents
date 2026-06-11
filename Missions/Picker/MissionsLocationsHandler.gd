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


func _ready() -> void:
	mouse_entered.connect(mouse_state_changed.bind(true))
	mouse_exited.connect(mouse_state_changed.bind(false))


func mouse_state_changed(entered : bool) -> void:
	var tween := get_tree().create_tween()

	if entered:
		tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.25)
		# create_information_text()
	else:
		tween.tween_property(self, "scale", Vector2(1,1), 0.25)