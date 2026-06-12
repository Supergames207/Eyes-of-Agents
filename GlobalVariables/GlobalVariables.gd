extends Node

@warning_ignore("unused_signal") #TODO Add a loading screen and make so game_load is ONLY called when the whole game loads ;)
signal game_loaded
signal day_ended
signal start_day_summary

signal day_started

signal closing_game

const day_duration_sec :=  1 * 60
const day_duration := day_duration_sec * 1000

var is_game_loaded := false

var main_scene : MainScene
var player : Player
var main_viewport : SubViewport

var global_perk_holder : PerkHolder

var current_day : int = 0
var day_time_ms : int = 0
var day_time : float = 0.0

var day_start := 0

var day_on_hold := 0

func _init() -> void:
	game_loaded.connect(update_game_loaded_state)

func update_game_loaded_state() -> void:
	is_game_loaded = true
	day_start = Time.get_ticks_msec()

##THIS IS A COROUTINE USE ``await`` .Should be used instead of just ``await game_loaded``
func wait_till_game_loaded() -> void: 
	if is_game_loaded:
		return
	
	await game_loaded

func _process(_delta: float) -> void:
	if day_on_hold > 0 or not is_game_loaded:
		return
	
	day_time_ms = Time.get_ticks_msec() - day_start

	day_time = day_time_ms / 1000.0

	if day_time_ms > day_duration:
		@warning_ignore("integer_division")
		current_day = floori(Time.get_ticks_msec() / day_duration)
		
		day_ended.emit()
		start_day_summary.emit()
		day_start = Time.get_ticks_msec()

		if day_on_hold == 0:
			day_started.emit()
		prints("NEXT DAY", current_day)

	#prints("DAY TIME", day_time)

func change_day_on_hold_state(state : bool, reset_time : bool = false) -> void:
	assert(day_on_hold >= 0)

	day_on_hold += 1 if state else -1

	if day_on_hold == 0 and reset_time:
		day_start = Time.get_ticks_msec()
	else:
		day_start = Time.get_ticks_msec() - day_time_ms

	if day_on_hold == 0:
		day_started.emit()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		closing_game.emit()
