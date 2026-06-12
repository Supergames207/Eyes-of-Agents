extends Control

@onready var agent_card_control_template: Control = $CardTemplate
var original_x := 0.0

@onready var dice := $Dice
@onready var popup_ui: Control = $"../Popup"

var agent_array: AgentArray

var rng_event_timer: float = 0.0
var rng_event_interval: float = 10.0

var current_missions: int
var active_cards: Array = []

var rolling: bool = false

func _ready() -> void:
	agent_array = GlobalVariables.player.agents


func _process(delta: float) -> void:
	rng_event_timer += delta
	for a in agent_array.agents:
		if not a.mission_status["RngEvent"] and a.mission_status["State"]:
			if rng_event_timer >= rng_event_interval:
				rng_event_timer = 0.0
				_do_rng(a)

func _do_rng(agent: Agent) -> void:
	#Set up agent card
	agent.mission_status["RngEvent"] = true
	
	var agent_card_control := agent_card_control_template.duplicate()
	var agent_card: AgentCardUI = agent_card_control.get_node("AgentCard")
	agent_card.fill_data(agent)
	agent_card.visible = true
	agent_card_control.position.x = -150.0
	agent_card_control.position.y = active_cards.size() * 100.0 + agent_card_control.position.y
	agent_card_control.visible = true
	add_child(agent_card_control)
	active_cards.append(agent_card_control)
	
	# Get Ui variables
	var scenario_container: VBoxContainer = agent_card_control.get_node("ScenarioMission")
	var prompt_label: Label = agent_card_control.get_node("ScenarioMission/PrompContainer/PromptLabel")
	var yes_button: Button = agent_card_control.get_node("ScenarioMission/Option/YesContainer/Button")
	var yes_stakes: Label = agent_card_control.get_node("ScenarioMission/Option/YesContainer/Stakes")
	var no_button: Button = agent_card_control.get_node("ScenarioMission/Option/NoContainer/Button")
	var no_stakes: Label = agent_card_control.get_node("ScenarioMission/Option/NoContainer/Stakes")
	

	agent.mission_ended.connect(func(_survived : bool) -> void:
		prints("HEY????", agent.name, agent.index)
		if is_instance_valid(agent_card_control):
			active_cards.erase(agent_card_control)
			agent_card_control.queue_free()
			scenario_container.visible = false
		
		,CONNECT_ONE_SHOT)
	
	var tween: Tween = create_tween()
	tween.tween_property(agent_card_control, "position:x", original_x, 0.5)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_BACK)
	tween.play()
	
	#Choose mission
	var random_mission: Dictionary = RandomStrings.random_rng_event.pick_random()
	var chance: int = random_mission["Chance"]
	
	#Show mission
	agent_card.pressed.connect(func() -> void:
		if scenario_container.visible:
			scenario_container.visible = false
			return
		
		for m: Control in active_cards:
			m.get_node("ScenarioMission").visible = false
			m.get_node("PuzzleMission").visible = false
		
		scenario_container.visible = true
		prompt_label.text = random_mission["text"]
		yes_stakes.text = "Chance: >" + str(chance) + "\nSurvivability: " + str(random_mission["Y_Survivability"]) + "%"
		no_stakes.text = "Survivability: " + str(random_mission["N_Survivability"]) + "%"
		
		if not yes_button.pressed.is_connected(on_yes_button):
			yes_button.pressed.connect(on_yes_button.bind(agent, agent_card_control, random_mission["Y_Survivability"], scenario_container))
		if not no_button.pressed.is_connected(on_no_button):
			no_button.pressed.connect(on_no_button.bind(agent, agent_card_control, scenario_container))
	)

func on_yes_button(agent: Agent, agent_card_control: Control, chance: int, scenario_container: VBoxContainer) -> void:
	print(agent.name)
	if rolling:
		popup_ui._new_notification("The dice Is already rolling!", Color(randf(), randf(), randf()))
		return
	
	rolling = true
	var dice_int: int = await dice._roll_dice() + 1
	if dice_int >= chance:
		agent.mission_status["Risk"] -= float(chance) / 100.0
	else:
		agent.mission_status["Risk"] += float(chance) / 100.0
	
	agent.mission_status["Risk"] = clampf(agent.mission_status["Risk"], 0, 1) #CHECK THIS, ok? It's just a workaround.
	#The calculations on themselves should guarantee that Risk is never bigger than 1

	active_cards.erase(agent_card_control)
	agent_card_control.queue_free()
	rolling = false
	scenario_container.visible = false
	popup_ui._new_notification(agent.name + " Risk: " + str(agent.mission_status["Risk"] * 100) + "%", Color(randf(), randf(), randf()))


func on_no_button(agent: Agent, agent_card_control: Control, scenario_container: VBoxContainer) -> void:
	print(agent.name)
	#The calculations on themselves should guarantee that Risk is never bigger than 1

	active_cards.erase(agent_card_control)
	agent_card_control.queue_free()
	scenario_container.visible = false
