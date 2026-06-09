extends Control

@onready var bg: ColorRect = $BackGround
@onready var control_template: Control = $CardsSurvival/CardTemplate
@onready var day_label: Label = $CurrentDay
@onready var day_label_stand: Label = $CurrentDayStandPoint
@onready var money_sum_label: Label = $Money
@onready var expenses_label: Label = $Money/Expenses
@onready var gains_label: Label = $Money/Gains
@onready var continue_label: Label = $ContinueNotice

signal clicked

var original_bg_y: float
var agent_array: AgentArray
var player: Player

var total_reward: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	original_bg_y = bg.position.y
	await GlobalVariables.wait_till_game_loaded()
	player = GlobalVariables.player
	agent_array = player.agents
	
	GlobalVariables.day_ended.connect(_start_summary)

func _start_summary() -> void:
	visible = true
	var current_day: int = GlobalVariables.current_day - 1
	var current_cash: int = player.money
	var expenses: int = player.adjacent_money_losses
	var gains: int = int(GlobalPerkHolder.get_perk_value("DaySalary"))
	var waiting_money: int = player.waiting_money
	var paycheck := roundi(GlobalPerkHolder.get_perk_value("DaySalary"))
	
	# Set the background
	
	bg.position.y -= bg.size.y
	
	var tween_bg: Tween = create_tween()
	tween_bg.tween_property(bg, "position:y", original_bg_y, 0.5)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_CUBIC)
	
	await tween_bg.finished
	
	# Give day
	day_label.text = "DAY " + str(current_day)
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
	
	day_label_stand.text = "DAY " + str(current_day)
	await _fade_in(day_label_stand, 0.4)
	day_label.visible = false
	day_label.modulate.a = 1
	
	# Team survival decision \\(WIP)//
	for a in agent_array.agents:
		if a.mission_status["State"]:
			a.mission_status["Duration"] -= 1
			if a.mission_status["Duration"] <= 0:
				waiting_money += a.mission_status["Reward"]
				# TWEens to be made
			  
	
	# money summary
	await _fade_in(money_sum_label, .25)
	
	for i: int in current_cash:
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		money_sum_label.text = "TOTAL CASH: " + str(i) + " $"
	
	money_sum_label.text = "TOTAL CASH: " + str(current_cash) + " $"
	
	await _fade_in(expenses_label, .25)
	
	for i: int in expenses:
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		expenses_label.text = "Expenses: " + str(i) + " $"
	expenses_label.text = "Expenses: " + str(expenses) + " $"
	
	await _fade_in(gains_label, .25)
	
	for i: int in gains:
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		gains_label.text = "Gains: " + str(i) + " $"
	gains_label.text = "Gains: " + str(gains) + " $"
	
	waiting_money = roundi(waiting_money * GlobalPerkHolder.get_perk_value("MoneyMultiplier"))
	
	player.money += waiting_money + paycheck - agent_array.overall_cost - expenses
	player.waiting_money = 0
	player.adjacent_money_losses = 0
	
	if player.money < 0:
		player._end_game()
	
	for i in range(current_cash, player.money):
		await RenderingServer.frame_post_draw
		money_sum_label.text = "TOTAL CASH: %d $" % i
	
	money_sum_label.text = "TOTAL CASH: " + str(current_cash) + " $"
	
	await _fade_in(continue_label)
	
	clicked.connect(func()->void:
		for c in get_children():
			if c == bg: continue
			c.visible = false
			for d in c.get_children():
				d.visible = false
		
		var tween_bg_2: Tween = create_tween()
		tween_bg_2.tween_property(bg, "position:y", bg.position.y - bg.size.y, 0.5)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_CUBIC)
		
		await tween_bg_2.finished
		
		visible = false
	)
	

func _fade_in(node: CanvasItem, duration: float = 0.4) -> void:
	node.modulate.a = 0
	node.visible = true

	var tween := create_tween()
	tween.tween_property(node, "modulate:a", 1.0, duration)
	await tween.finished

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			clicked.emit()
