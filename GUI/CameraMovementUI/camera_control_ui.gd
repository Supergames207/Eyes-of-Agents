extends Control

@onready var player: Node3D = GlobalVariables.player
var left_button: Button
var right_button: Button

func _ready() -> void:
	left_button = $LeftButton
	right_button = $RightButton
	left_button.pressed.connect(_on_button_press.bind(0))
	right_button.pressed.connect(_on_button_press.bind(1))

func _process(_delta: float) -> void:
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var screen_width: float = get_viewport().get_visible_rect().size.x
	left_button.visible = mouse_pos.x < screen_width * 0.075
	right_button.visible = mouse_pos.x > screen_width * 0.925

func _on_button_press(side: int) -> void:
	if side == 0:
		player.global_rotation.y += PI/2
	else: if side == 1:
		player.global_rotation.y -= PI/2
