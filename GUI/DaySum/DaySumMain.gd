extends Control

@onready var bg: ColorRect = $BackGround

@onready var day_label: Label = $CurrentDay
@onready var day_label_stand: Label = $CurrentDayStandPoint

@onready var control_template: Control = $CardsSurvival/CardTemplate

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
	GlobalVariables.change_day_on_hold_state(true, true)

	visible = true
	var current_day := GlobalVariables.current_day - 1
	var current_cash := player.money
	var expenses := player.adjacent_money_losses + agent_array.overall_cost
	var gains := roundi(GlobalPerkHolder.get_perk_value("DaySalary"))
	var waiting_money: int = player.waiting_money
	# var paycheck := roundi(GlobalPerkHolder.get_perk_value("DaySalary"))
	
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
			var control: Control = control_template.duplicate()
			control.visible = true
			var card: AgentCardUI = control.get_node("AgentCard")
			var x_texture: TextureRect = control.get_node("DeadTexture")
			var chance_label: Label = control.get_node("Chance")
			var survival_label: Label = control.get_node("SurvivalState")
			
			var chance: float = a.mission_status["Risk"]
			
			a.mission_status["Duration"] -= 1
			
			card.fill_data(a)
			chance_label.text = str(round(chance * 100)) + " %"
			
			if randf() < chance:
				agent_array.remove_agent(a)
				
				x_texture.size = Vector2(2.1, 2.1)
				var tween_x: Tween = create_tween()
				tween_x.tween_property(x_texture, "scale", Vector2(1, 1), .4)
				await _fade_in(x_texture, .4)
				
				survival_label.text = "Compromised"
				set("theme_override_colors/font_color", Color(.9, .0, .2, 1.0))
				await _fade_in(survival_label, .2)
				await get_tree().create_timer(1.5).timeout
				control.queue_free()
				
				continue
			else:
				survival_label.text = "Safe"
				set("theme_override_colors/font_color", Color(.4, .9, .3, 1.0))
				await _fade_in(survival_label, .3)
				if a.mission_status["Duration"] <= 0:
					waiting_money += a.mission_status["Reward"]
				await get_tree().create_timer(.3).timeout
				await get_tree().create_timer(1.8).timeout
				control.queue_free()
	
	# money summary
	await _fade_in(money_sum_label, .25)
	
	for i: int in current_cash:
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		money_sum_label.text = "TOTAL CASH: " + str(i) + " $"
	
	money_sum_label.text = "TOTAL CASH: " + str(current_cash) + " $"

	await _fade_in(expenses_label, .25)
	
	for i: int in range(0, expenses, expenses / 5.0):
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		expenses_label.text = "Expenses: " + str(i) + " $"
	expenses_label.text = "Expenses: " + str(expenses) + " $"
	
	await _fade_in(gains_label, .25)
	
	waiting_money = roundi(waiting_money * GlobalPerkHolder.get_perk_value("MoneyMultiplier"))
	gains += waiting_money

	for i: int in range(0, gains, gains / 5.0):
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		gains_label.text = "Gains: " + str(i) + " $"
	gains_label.text = "Gains: " + str(gains) + " $"
	
	

	player.money += gains - expenses
	player.waiting_money = 0
	player.adjacent_money_losses = 0
	
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

		if player.money < 0:
			player.end_game()
		else:
			GlobalVariables.change_day_on_hold_state(false, true)
		,
		CONNECT_ONE_SHOT
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
