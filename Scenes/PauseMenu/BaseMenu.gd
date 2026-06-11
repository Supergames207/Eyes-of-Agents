class_name BaseMenu extends Control

var menu_before : BaseMenu

var open_state := false

func _ready() -> void:
	visible = open_state

func change_menu_state(open : bool, from : BaseMenu = null) -> void:
	if open == open_state:
		return
	
	open_state = open

	visible = open_state
	
	if open_state and from:
		menu_before = from
		GlobalVariables.player.current_menu = self
	elif open_state:
		menu_before = null
	
	if not open_state and menu_before:
		menu_before.change_menu_state(true)
		menu_before = null

