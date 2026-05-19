extends Button


func _ready():
    pressed.connect(test)

func test():
    prints("PRESSED")