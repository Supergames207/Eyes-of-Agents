extends Node

@warning_ignore("unused_signal") #TODO Add a loading screen and make so game_load is ONLY called when the whole game loads ;)
signal game_loaded

var is_game_loaded := false

var player : Player
var main_viewport : SubViewport


func _init() -> void:
	game_loaded.connect(update_game_loaded_state)

func update_game_loaded_state() -> void:
	is_game_loaded = true

##THIS IS A COROUTINE USE ``await`` .Should be used instead of just ``await game_loaded``
func wait_till_game_loaded() -> void: 
	if is_game_loaded:
		return
	
	await game_loaded
