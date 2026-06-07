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


func update_max_collums(control : Control) -> void:
	var parent : SubViewport = get_parent()

	var max_cols := floori(parent.size.x / control.get_combined_minimum_size().x)
	get_node("PanelContainer/CenterContainer/ScrollContainer/AgentCardHolder").columns = max_cols

func populate() -> void:
	var grid : GridContainer = get_node("PanelContainer/CenterContainer/ScrollContainer/AgentCardHolder")

	for k in range(agents_array.agents.size()):
		var new : AgentCardUI = agent_card.instantiate()
		new.agent = agents_array.agents[k]

		grid.add_child(new)

		if k == 0 and get_parent() is SubViewport:
			update_max_collums(new)

func update_agent_visualizer(added : bool, index : int) -> void:
	if added:
		var new : AgentCardUI = agent_card.instantiate()
		new.agent = agents_array.agents[index]

		get_node("PanelContainer/CenterContainer/ScrollContainer/AgentCardHolder").add_child(new)
		
		update_max_collums(new) 
	else:
		get_node("PanelContainer/CenterContainer/ScrollContainer/AgentCardHolder").get_child(index).queue_free()
	
