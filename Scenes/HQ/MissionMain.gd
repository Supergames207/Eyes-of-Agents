extends Control

@onready var loc_container := $LocationsContainer
@onready var risk_label := $RiskLabel
@onready var loc_label := $LocationLabel
@onready var obj_label := $ObjectiveLabel


func _ready() -> void:
	NewMissions._new_missions(loc_container)
	for l in loc_container.get_children():
		
		l.pressed.connect(func(): _on_press(l.danger, l.location, l.objective))

func _on_press(_danger: float, _loc: String, _obj: String) -> void:
	loc_label.text = "Location: " + _loc
	obj_label.text = "Objective: " + _obj
	
