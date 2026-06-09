extends Control

const main_scene_path := "res://Scenes/MainScene.tscn"

func _ready() -> void:
    get_node("Clickables/Play").gui_input.connect(start_game)
    get_node("Clickables/Credits").gui_input.connect(show_credits)

    get_node("Clickables/Play").mouse_entered.connect(mouse_entered_button)
    get_node("Clickables/Credits").mouse_entered.connect(mouse_entered_button)
    

    get_node("LoadingScreen").loaded.connect(main_scene_loaded)

func start_game(_event : InputEvent) -> void:
    if not Input.is_action_just_pressed("Click"):
        return
    
    var sound : AudioStreamPlayer = get_node("Sounds/MenuSelect")
    sound.play()

    get_node("LoadingScreen").visible = true
    get_node("LoadingScreen").start_loading(main_scene_path)

func show_credits(_event : InputEvent) -> void:
    if not Input.is_action_just_pressed("Click"):
        return
    
    var sound : AudioStreamPlayer = get_node("Sounds/MenuSelect")
    sound.play()
    get_node("Credits").visible = true

func main_scene_loaded(res : Resource) -> void:
    var scene : PackedScene = res

    get_tree().change_scene_to_packed(scene)


func mouse_entered_button() -> void:
    var sound : AudioStreamPlayer = get_node("Sounds/MenuMouseEntered")
    sound.play()