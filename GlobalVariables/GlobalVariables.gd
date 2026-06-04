extends Node

@warning_ignore("unused_signal") #TODO Add a loading screen and make so game_load is ONLY called when the whole game loads ;)
signal game_loaded
signal day_ended


const day_duration := 1 * 60 * 1000

var is_game_loaded := false

var player : Player
var main_viewport : SubViewport

var global_perk_holder : PerkHolder

var current_day : int = 0
var day_time_ms : int = 0
var day_time : float = 0.0

func _init() -> void:
	game_loaded.connect(update_game_loaded_state)

func update_game_loaded_state() -> void:
	is_game_loaded = true

##THIS IS A COROUTINE USE ``await`` .Should be used instead of just ``await game_loaded``
func wait_till_game_loaded() -> void: 
	if is_game_loaded:
		return
	
	await game_loaded

func _process(_delta: float) -> void:
	day_time_ms = Time.get_ticks_msec() - current_day * day_duration
	day_time = day_time_ms / 1000.0

	if day_time_ms > day_duration:
		@warning_ignore("integer_division")
		current_day = floori(Time.get_ticks_msec() / day_duration)

		day_ended.emit()
		prints("NEXT DAY", current_day)
