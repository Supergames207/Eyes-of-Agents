class_name LocationButton extends Button

@export var risk: float:
	set(value):
		risk = value
		_on_property_changed("risk", value)

@export var location: String:
	set(value):
		location = value
		_on_property_changed("location", value)

@export var objective: String:
	set(value):
		objective = value
		_on_property_changed("objective", value)

@export var reward: int:
	set(value):
		reward = value
		_on_property_changed("reward", value)

func _on_property_changed(_property: String, _value: Variant) -> void:
	text = str(location) + " | RISK: " + str(risk)


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
