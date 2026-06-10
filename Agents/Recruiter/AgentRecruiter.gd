class_name AgentRecruiter extends Control

const agent_card_path := "res://Agents/AgentCard.tscn"

var agent_card : PackedScene = preload(agent_card_path)


var assault_skill_gaussian : GaussianData
var furtive_skill_guassian : GaussianData

func _ready() -> void:
	populate()
	GlobalVariables.day_ended.connect(populate)

func populate() -> void:
	assault_skill_gaussian = GaussianData.new(GlobalPerkHolder.get_perk_value("AssaultSkillMean"), 
											GlobalPerkHolder.get_perk_value("AssaultSkillDeviation"))
	
	furtive_skill_guassian = GaussianData.new(GlobalPerkHolder.get_perk_value("FurtiveSkillMean"), 
											GlobalPerkHolder.get_perk_value("FurtiveSkillDeviation"))

	var grid : GridContainer = get_node("PanelContainer/CenterContainer/ScrollContainer/AgentCardHolder")
	
	for k in grid.get_children():
		k.queue_free()
	

	for k in range(GlobalPerkHolder.get_perk_value("AgentRecruiterSlots")):
		var new : AgentCardUI = agent_card.instantiate()

		var random_agent := generate_random_agent()
		new.agent = random_agent

		grid.add_child(new)
		
		new.pressed.connect(attempt_agent_recruitment.bind(new))

		# if k == 0 and get_parent() is SubViewport:
		# 	var parent : SubViewport = get_parent()

		# 	# var max_cols := floori(parent.size.x / new.get_combined_minimum_size().x)
		# 	# grid.columns = max_cols


func generate_random_agent() -> Agent:
	var new_agent := Agent.new()

	new_agent.name = RandomStrings.random_names.pick_random()
	
	new_agent.assault_skill = new_agent.assault_skill_range.make_within_range(assault_skill_gaussian.get_random())
	new_agent.furtiveness_skill = new_agent.furtiveness_skill_range.make_within_range(furtive_skill_guassian.get_random())
	
	new_agent.cost = roundi((new_agent.assault_skill + new_agent.furtiveness_skill) * (15.0 + randf_range(-5, 5) ))
	return new_agent


func attempt_agent_recruitment(pressed_card : AgentCardUI) -> void:
	AudioManager.play("res://Sounds/Pack2/GUI Sound Effects_062.wav", 1.0, 1.05, -10.0)

	var agent_array := GlobalVariables.player.agents
	
	agent_array.add_agent(pressed_card.agent)
	pressed_card.queue_free()
	
