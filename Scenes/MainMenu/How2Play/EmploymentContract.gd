extends TextureRect


func _ready() -> void:
    get_node("CloseButton").pressed.connect(close)

func close() -> void:
    visible = false


