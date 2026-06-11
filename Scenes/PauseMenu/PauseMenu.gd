class_name PauseMenu extends BaseMenu


func _ready() -> void:
	get_node("VBoxContainer/Resume").pressed.connect(resume)
	get_node("VBoxContainer/Options").pressed.connect(open_options)
	get_node("VBoxContainer/NewRun").pressed.connect(start_new_run)
	get_node("VBoxContainer/Quit").pressed.connect(quit)

	visible = open_state

func change_menu_state(open : bool, from : BaseMenu = null) -> void:
	super(open, from)

	GlobalVariables.change_day_on_hold_state(open_state)
	

func resume() -> void:
	change_menu_state(false)

func open_options() -> void:
	change_menu_state(false)
	get_parent().get_node("OptionsMenu").change_menu_state(true, self)

func start_new_run() -> void:
	var scene : PackedScene = load("res://Scenes/MainMenu/MainMenu.tscn")
	get_tree().change_scene_to_packed(scene)

func quit() -> void:
	get_tree().quit()
