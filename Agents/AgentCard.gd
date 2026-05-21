class_name AgentCardUI extends PanelContainer

var agent : Agent


func _ready() -> void:
	if agent:
		fill_data()

func fill_data() -> void:
	get_node("VBoxContainer/Name").text = agent.name
	get_node("VBoxContainer/Data").text = "Cost :" + str(agent.cost) + " $ \n" \
										+ "Stealth" + str(agent.furtiveness_skill) + "\n" \
										+ "Assault" + str(agent.assault_skill)
	
