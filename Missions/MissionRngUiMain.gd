extends Control

@onready var agent_card_control_template: Control = $CardTemplate
var original_x := 0.0

@onready var main_container: VBoxContainer = $VBoxContainer
@onready var prompt_label: Label = $VBoxContainer/PrompContainer/PromptLabel
@onready var prompt_face: TextureRect = $VBoxContainer/PrompContainer/AgentFace
@onready var yes_button: Button = $VBoxContainer/Option/YesContainer/Button
@onready var yes_stakes: Label = $VBoxContainer/Option/YesContainer/Stakes
@onready var no_button: Button = $VBoxContainer/Option/NoContainer/Button
@onready var no_stakes: Label = $VBoxContainer/Option/NoContainer/Stakes
@onready var dice := $Dice

var agent_array: AgentArray

var rng_event_timer: float = 0.0
var rng_event_interval: float = 10.0

var current_missions: int

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
		else: return

func _do_rng(agent: Agent) -> void:
	agent.mission_status["RngEvent"] = true
	
	var agent_card_control := agent_card_control_template.duplicate()
	var agent_card: AgentCardUI = agent_card_control.get_node("AgentCard")
	agent_card.fill_data(agent)
	agent_card_control.position.x = -150.0
	agent_card_control.visible = true
	add_child(agent_card_control)  # make sure it's in the tree before tweening
	
	var tween: Tween = create_tween()
	tween.tween_property(agent_card_control, "position:x", original_x, 0.5)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_BACK)
	tween.play()
	
	var random_mission: Dictionary = RandomStrings.random_rng_event.pick_random()
	var chance: int = random_mission["Chance"]
	main_container.visible = true
	prompt_label.text = random_mission["text"]
	yes_stakes.text = "Chance: >" + str(chance) + "\nSurvivability: " + str(random_mission["Y_Survivability"]) + "%"
	no_stakes.text = "Survivability: " + str(random_mission["N_Survivability"]) + "%"
	
	yes_button.pressed.connect(func() -> void:
		if rolling: return
		
		rolling = true
		var dice_int: int = await dice._roll_dice() + 1
		if dice_int >= chance:
			agent.mission_status["Risk"] *= 1 + 1/float(chance) 
		else:
			agent.mission_status["Risk"] *= 1 - 1/float(chance)
		
		# notification system
		
		agent_card_control.queue_free()
		rolling = false
		main_container.visible = false
	)
