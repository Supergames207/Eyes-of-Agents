class_name AgentArray extends Resource

@export var agents : Array[Agent]

signal array_changed

func add_agent(agent : Agent) -> void:
	agents.push_back(agent)
	agent.index = agents.size() - 1

	array_changed.emit(true, agent.index)

func remove_agent(agent : Agent) -> void:
	agents.remove_at(agent.index)

	for k in range(agent.index, agents.size()):
		agents[k].index -= 1
	
	array_changed.emit(false, agent.index)
