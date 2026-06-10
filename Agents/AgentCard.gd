class_name AgentCardUI extends PanelContainer

signal pressed

var agent : Agent


func _ready() -> void:
	if agent:
		fill_data(agent)

func fill_data(_agent: Agent) -> void:
	get_node("VBoxContainer/Name").text = _agent.name
	get_node("VBoxContainer/Data").text = "Cost per day:" + str(_agent.cost) + " $ \n" \
										+ "Stealth : " + str(_agent.furtiveness_skill) + "\n" \
										+ "Assault : " + str(_agent.assault_skill)
	
func _gui_input(e : InputEvent) -> void:
	if e is InputEventMouseButton:
		var event : InputEventMouseButton = e
		
		if not event.pressed and event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
			pressed.emit()
			accept_event()
		
