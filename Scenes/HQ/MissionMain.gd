extends Control

@onready var loc_container := $LocationsContainer
@onready var danger_label := $DangerLabel
@onready var loc_label := $LocationLabel
@onready var obj_label := $ObjectiveLabel
@onready var agent_card := $AgentCard
@onready var next_agent_button := $NextAgent
@onready var accept_button := $Accept

var current_agent: int = 0
var agent_array: AgentArray

var current_loc: Button

func _ready() -> void:
	await GlobalVariables.wait_till_game_loaded()
	
	NewMissions._new_missions(loc_container)
	
	agent_array = GlobalVariables.player.agents
	
	for l in loc_container.get_children():
		@warning_ignore("untyped_declaration")
		l.pressed.connect(func(): _on_pin_press(l.danger, l.location, l.objective, l))
	
	@warning_ignore("untyped_declaration")
	next_agent_button.pressed.connect(func(): _on_next_agent())
	
	@warning_ignore("untyped_declaration")
	accept_button.pressed.connect(func(): _on_acceptance())

func _on_pin_press(_danger: float, _loc: String, _obj: String, pin: Button) -> void:
	current_loc = pin
	loc_label.text = "Location: " + _loc
	obj_label.text = "Objective: " + _obj
	danger_label.text = "Danger: " + str(_danger)

func _on_next_agent() -> void:
	current_agent = (current_agent + 1) % agent_array.agents.size()
	var next_agent: Agent = agent_array.agents[current_agent]
	agent_card.fill_data(next_agent)

func _on_acceptance() -> void:
	var agent: Agent = agent_array.agents[current_agent]
	if agent.mission_status["State"]:
		print("Agent " + agent.name + " already has an active mission")
		return
	
	agent.mission_status["State"] = true
	agent.mission_status["Objective"] = RandomStrings.random_objectives.find(current_loc.objective)
	agent.mission_status["Duration"] = 1
	agent.mission_status["Location"] = RandomStrings.random_locations.find(current_loc.location)
	
	print(agent.mission_status)
