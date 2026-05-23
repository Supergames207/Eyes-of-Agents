class_name AgentPicker extends Control

const agent_card_path := "res://Agents/AgentCard.tscn"

var agent_card : PackedScene = preload(agent_card_path)

var agents_array : AgentArray


func _ready() -> void:
	await GlobalVariables.wait_till_game_loaded()

	agents_array = GlobalVariables.player.agents

	if not agents_array:
		return

	populate()
	agents_array.array_changed.connect(update_agent_visualizer)


func populate() -> void:
	for k in range(agents_array.agents.size()):
		var new : AgentCardUI = agent_card.instantiate()
		new.agent = agents_array.agents[k]

		get_node("PanelContainer/CenterContainer/AgentCardHolder").add_child(new)

func update_agent_visualizer(added : bool, index : int) -> void:
	if added:
		var new : AgentCardUI = agent_card.instantiate()
		new.agent = agents_array.agents[index]

		get_node("PanelContainer/CenterContainer/AgentCardHolder").add_child(new)
	else:
		get_node("PanelContainer/CenterContainer/AgentCardHolder").get_child(index).queue_free()
	
	prints("UPDATED?!?!")
