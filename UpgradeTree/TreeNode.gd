@tool
class_name TreeNode extends Control


@export_tool_button("Organize Links") var organizor := organize_links
@export var links : Array[TreeNode]

@export var locked_texture : Texture2D
@export var unlocked_texture : Texture2D

const padding := Vector2(10,10)

var locked := true:
	set(value):
		locked = value
		update_visuals()

var parents_unlocked := 0
var parents_count := 0

var ID : int #TODO ADD IDs. With an ID I'll be able to store and load from disk if this node has already been unlocked.


func _ready() -> void:
	for k in get_children():
		if k is Line2D:
			k.queue_free()
	
	create_connection_lines()
	update_visuals()

	for k in links:
		k.parents_count += 1

	mouse_entered.connect(mouse_state_changed.bind(true))
	mouse_exited.connect(mouse_state_changed.bind(false))


func update_visuals() -> void: #TODO maybe like a grayer node when it can't be unlocked yet??!?
	if not is_node_ready():
		return
	
	if parents_unlocked < parents_count:
		get_node("Background").texture = locked_texture
	else:
		get_node("Background").texture = unlocked_texture


func create_connection_lines() -> void:	#TODO Draw some lines 
	if not is_node_ready():
		return
	
	for tree_node in links:
		var new := Line2D.new()
		new.position = Vector2(size.x, size.y / 2.0)
		add_child(new)
		new.owner = owner

		var target_position := (tree_node.global_position + Vector2(0, size.y / 2.0))
		
		new.add_point(Vector2.ZERO)
		new.add_point(target_position - new.global_position)
	

func _gui_input(e : InputEvent) -> void:
	if e is InputEventMouseButton:
		var event : InputEventMouseButton = e

		if event.button_index == MOUSE_BUTTON_LEFT:
			unlock() #TODO Some logic to define if I can unlock this thingy

func unlock() -> void:
	locked = false

	for tree_node in links:
		tree_node.parents_unlocked += 1

func organize_links() -> void:
	for k in range(links.size()):
		links[k].global_position = global_position + Vector2(1, k - links.size() / 2.0 + 0.5) * (custom_minimum_size + padding)

func mouse_state_changed(entered : bool) -> void:
	get_node("InformationHolder").visible = entered
