extends Control

@onready var bg: ColorRect = $BackGround
@onready var control_template: Control = $CardsSurvival/CardTemplate
@onready var day_label: Label = $CurrentDay
@onready var day_label_stand: Label = $CurrentDayStandPoint
@onready var money_sum_label: Label = $Money
@onready var expenses_label: Label = $Money/Expenses
@onready var gains_label: Label = $Money/Gains

var agent_array: AgentArray
var player: Player

var total_reward: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await GlobalVariables.wait_till_game_loaded()
	player = GlobalVariables.player
	agent_array = player.agents
	
	await _start_summary()

func _start_summary() -> void:
	visible = true
	var current_cash: int = 500
	var expenses: int = 20
	
	# Set the background
	var original_bg_y: float = bg.position.y
	bg.position.y -= bg.size.y
	
	var tween_bg: Tween = create_tween()
	tween_bg.tween_property(bg, "position:y", original_bg_y, 0.5)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_CUBIC)
	
	await tween_bg.finished
	
	# Give day
	day_label.scale = Vector2(0, 0)
	day_label.visible = true
	
	var tween_day: Tween = create_tween()
	tween_day.tween_property(day_label, "scale", Vector2(1, 1), .7)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_QUAD)
	
	await get_tree().create_timer(3.0).timeout
	
	var tween_day_fade_out: Tween = create_tween()
	tween_day_fade_out.tween_property(day_label, "modulate:a", 0, .4)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_LINEAR)
	
	day_label_stand.modulate.a = 0
	day_label_stand.visible = true
	
	var tween_day_fade_in: Tween = create_tween()
	tween_day_fade_in.tween_property(day_label_stand, "modulate:a", 1, .4)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_LINEAR)
	
	await  tween_day_fade_in.finished
	
	# Team survival decision \\(WIP)//
	#for a in agent_array.agents:
		#if a.mission_status["State"]:
			#a.mission_status["Duration"] -= 1
			#if a.mission_status["Duration"] <= 0:
				#player.money += a.mission_status["Reward"]
				#total_reward += a.mission_status["Reward"]
				## TWEens to be made
			  #
	
	# money summary
	money_sum_label.modulate.a = 0
	money_sum_label.visible = true
	
	var tween_money_fade_in: Tween = create_tween()
	tween_money_fade_in.tween_property(money_sum_label, "modulate:a", 1, .5)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_LINEAR)
	
	for i: int in current_cash:
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		money_sum_label.text = "TOTAL CASH: " + str(i) + " $"
	
	money_sum_label.text = "TOTAL CASH: " + str(current_cash) + " $"
	
	expenses_label.modulate.a = 0
	expenses_label.visible = true
	var tween_expenses: Tween = create_tween()
	tween_expenses.tween_property(expenses_label, "modulate:a", 1, .4)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_LINEAR)
	
	for i: int in expenses:
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		expenses_label.text = "Expenses: " + str(i) + " $"
	expenses_label.text = "Expenses: " + str(expenses) + " $"
	
	
