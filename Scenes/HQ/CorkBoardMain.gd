extends Control

@onready var button: Button = $Button

func _ready() -> void:
	button.pressed.connect(_on_button_press)
	

func _on_button_press():
	print("BUTTON PRESSED")
