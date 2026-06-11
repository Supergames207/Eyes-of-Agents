extends Control


var isRolling: bool = false
var currentIndex: int = 0

func _ready() -> void:
	_set_start_face()

func _set_start_face() -> void:
	for face in get_children():
		face.hide()
		
	get_child(0).show()

func _roll_dice() -> int:
	var duration := 1.0
	visible = true
	isRolling = true
	
	while duration > 0:
		var newIndex: int = get_children().pick_random().get_index()
		get_child(currentIndex).hide()
		get_child(newIndex).show()
		
		await get_tree().create_timer(0.1).timeout
		
		currentIndex = newIndex
		duration -= 0.1
	
	isRolling = false
	
	await get_tree().create_timer(1).timeout
	visible = false
	
	return currentIndex
