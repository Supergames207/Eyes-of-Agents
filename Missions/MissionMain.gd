extends Control

var base_reward: int = 100

@onready var loc_container := $VHS/VBoxContainer
# @onready var button_template := $VBoxContainer/ButtonTemplate
@onready var risk_label := $PaperInfo/VBoxContainer/RiskLabel
@onready var reward_label := $PaperInfo/VBoxContainer/RewardLabel
@onready var loc_label := $PaperInfo/VBoxContainer/LocationLabel
@onready var obj_label := $PaperInfo/VBoxContainer/ObjectiveLabel
@onready var agent_card := $CardContainer/AgentCard
@onready var assign_card := $CardContainer/TextureRect
@onready var next_agent_button := $NextAgent
@onready var accept_button := $Accept
@onready var alr_assign := $AlreadyAssign

var button_template := preload("res://Missions/Picker/ButtonTemplate.tscn")

var current_agent: int = 0
var agent_array: AgentArray
var player: Player

var current_loc: Button

func _ready() -> void:
	await GlobalVariables.wait_till_game_loaded()
	player = GlobalVariables.player
	
	for n in range(0, GlobalPerkHolder.get_perk_value(&"MissionSlots")):
		var new_button: LocationButton = button_template.instantiate()
		loc_container.add_child(new_button)
	
	NewMissions._new_missions(loc_container)
	
	agent_array = GlobalVariables.player.agents
	
	for l in loc_container.get_children():
		if not l is LocationButton:
			continue
		
		l.mouse_entered.connect(button_mouse_entered)
		l.pressed.connect(func() -> void: _on_pin_press(l.risk, l.location, l.objective, l))
	
	next_agent_button.pressed.connect(func() -> void: _on_next_agent())
	
	accept_button.pressed.connect(func() -> void: _on_acceptance())
	
	_on_next_agent()

func button_mouse_entered() -> void:
	AudioManager.play("res://Sounds/Pack1/GUI Sound Effects_031.wav", 1.0, 1.05, -20.0)

func _on_pin_press(_risk: float, _loc: String, _obj: String, pin: Button) -> void:
	current_loc = pin
	var agent := agent_array.agents[current_agent]
	
	var values := _get_biased_values(_risk, agent)
	
	risk_label.text = "Danger: " + str(snapped(values["risk"], 0.1)) + "%"
	reward_label.text = "Reward: " + str(values["reward"])
	loc_label.text = "Location: " + _loc
	obj_label.text = "Objective: " + _obj
	
	AudioManager.play("res://Sounds/Pack2/GUI Sound Effects_062.wav", 1.0, 1.05, -10.0)

func _on_next_agent() -> void:
	if agent_array.agents.size() == 0:
		agent_card.visible = false
		assign_card.visible = true
		return
	
	agent_card.visible = true
	assign_card.visible = false
	current_agent = (current_agent + 1) % agent_array.agents.size()
	var next_agent: Agent = agent_array.agents[current_agent]
	agent_card.fill_data(next_agent)

	if next_agent.mission_status["State"]:
		alr_assign.visible = true
	else:
		alr_assign.visible = false

func _on_acceptance() -> void:
	if agent_array.agents.is_empty():
		AudioManager.play("res://Sounds/Pack2/GUI Sound Effects_063.wav", 1.0, 1.05, -10.)
		print("Player doesn't have any agents")
		return
	
	var agent: Agent = agent_array.agents[current_agent]

	if agent.mission_status["State"]:
		AudioManager.play("res://Sounds/Pack2/GUI Sound Effects_063.wav", 1.0, 1.05, -10.)
		print("Agent " + agent.name + " already has an active mission")
		return
	
	if not current_loc:
		AudioManager.play("res://Sounds/Pack2/GUI Sound Effects_063.wav", 1.0, 1.05, -10.)
		print("No mission/pin selected")
		return
	
	if not current_loc.objective or not current_loc.location:
		AudioManager.play("res://Sounds/Pack2/GUI Sound Effects_063.wav", 1.0, 1.05, -10.)
		print("No objective or location selected")
		return
	
	var objective: int = RandomStrings.random_objectives.find(current_loc.objective)
	var location: int = RandomStrings.random_locations.find(current_loc.location)
	var values: Dictionary = _get_biased_values(current_loc.risk, agent)
	
	agent.mission_status["State"] = true
	agent.mission_status["Objective"] = RandomStrings.random_objectives.find(current_loc.objective)
	agent.mission_status["Duration"] = 1
	agent.mission_status["Location"] = RandomStrings.random_locations.find(current_loc.location)
	agent.mission_status["Risk"] = values["risk"] / 100.0
	agent.mission_status["Reward"] = values["reward"]
	
	current_loc.queue_free()

	if agent.mission_status["State"]:
		alr_assign.visible = true
	else:
		alr_assign.visible = false
	
	print(agent.mission_status)
	AudioManager.play("res://Sounds/Pack2/GUI Sound Effects_061.wav", 1.0, 1.05, -10.)

func _get_biased_values(loc_risk: float, agent: Agent) -> Dictionary:
	var risk: float = clamp(current_loc.risk * \
	(1 - (((agent.assault_skill + agent.furtiveness_skill)/2 - 10) / 10) * .5),
	0.0,
	100.0)
	var reward: int = int(100 + loc_risk * 10)
	
	return {
		"risk": risk,
		"reward": reward
	}
