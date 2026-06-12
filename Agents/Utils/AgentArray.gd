class_name AgentArray extends Resource

signal array_changed

@export var agents : Array[Agent]

var overall_cost := 0

func add_agent(agent : Agent) -> void:
	agents.push_back(agent)
	agent.index = agents.size() - 1
	
	overall_cost += agent.cost
	
	array_changed.emit(true, agent.index)

func remove_agent(agent : Agent) -> void:
	assert(agents[agent.index] == agent, "Bruh. Tried to remove an agent with invalid index")
	
	agents.remove_at(agent.index)

	for k in range(agent.index, agents.size()):
		agents[k].index -= 1
		
	overall_cost -= agent.cost
	array_changed.emit(false, agent.index)

	agent.index = -1
	
