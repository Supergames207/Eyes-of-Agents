@tool
class_name UpgradeTree extends Control

const panning_sensivity := Vector2(1, 1)
const zoom_senvivity := 1

const zoom_bound := Vector2(-1, 1)
const scale_bound := Vector2(1, 10)

# const upgrade_resource_tree_path := "res://UpgradeTree/UpgradeResourceTree.tres"
const tree_state_path := "user://UpgradeTreeState"


var current_ID := 0
var ID_map : Dictionary[int, TreeNode] = {}
# @export_tool_button("Convert Editor Mess To Resource Tree") var convertor := convert_nodes_to_resource_tree
# @export_tool_button("Test Resource Tree Loading") var debug_loader := convert_resource_tree_to_nodes


func _ready() -> void:
	
	set_process(not Engine.is_editor_hint())

	var old_ID := 0

	for k in get_node("TreeNodes").get_children():
		if Engine.is_editor_hint():
			old_ID = max(old_ID, k.ID + 1)

		ID_map[k.ID] = k
	
	load_current_tree_state()

	if Engine.is_editor_hint():
		current_ID = old_ID

	GlobalVariables.closing_game.connect(save_current_tree_state)

func _gui_input(e : InputEvent) -> void:
	if e is InputEventMouseMotion:
		var event : InputEventMouseMotion = e

		if Input.is_action_pressed("Click"):
			global_position += event.screen_relative * panning_sensivity
			accept_event()

	elif Input.is_action_pressed("Zoom Out") or Input.is_action_pressed("Zoom In"): #ZOOM
		var old_pos := get_local_mouse_position()
		scale += Vector2.ONE * clampf(Input.get_axis("Zoom Out", "Zoom In"), zoom_bound.x, zoom_bound.y) * zoom_senvivity
		scale = scale.clampf(scale_bound.x, scale_bound.y)
		
		global_position = -old_pos * scale + get_global_mouse_position()

#TODO MAYBE THIS IS A BAD IDEA. JUST MAYBE
##ONLY TO BE USED WHILE ON THE EDITOR.
# func convert_nodes_to_resource_tree() -> void:
# 	var current_ID := 0

# 	var holder := get_node("TreeNodes")

# 	for k in holder.get_children():
# 		if not k is TreeNode:
# 			continue
		
# 		k.ID = current_ID
# 		current_ID += 1
	
# 	var resource_tree := ResourceTree.new()

# 	resource_tree.data = PackedInt32Array()
	
	
# 	for tree_node : TreeNode in holder.get_children():
# 		resource_tree.data.push_back(1 + 3 + tree_node.links.size()) #Size
# 		resource_tree.data.push_back(tree_node.ID)
# 		resource_tree.data.push_back(int(tree_node.position.x))
# 		resource_tree.data.push_back(int(tree_node.position.y))
		
# 		for link in tree_node.links:
# 			resource_tree.data.push_back(link.ID)
	
# 	ResourceSaver.save(resource_tree, upgrade_resource_tree_path)


# func convert_resource_tree_to_nodes() -> void:
# 	var resource_tree : ResourceTree = ResourceLoader.load(upgrade_resource_tree_path,  "", ResourceLoader.CACHE_MODE_IGNORE)
# 	var data := resource_tree.data

# 	var holder := get_node("TreeNodes")

# 	var index := 0

# 	ID_map = {}

# 	while index < data.size():
# 		var mem_size := data[index]

# 		var new_tree_node := TreeNode.new()

# 		new_tree_node.ID = data[index + 1]
# 		new_tree_node.position = Vector2(data[index + 2], data[index + 3])

# 		ID_map[new_tree_node.ID] = new_tree_node

# 		holder.add_child(new_tree_node)
# 		new_tree_node.owner = self

# 		index += mem_size
	
# 	index = 0

# 	while index < data.size():
# 		var mem_size := data[index]

# 		var tree_node := ID_map[data[index + 1]]

# 		for k in range(4, mem_size):
# 			tree_node.links.push_back(ID_map[data[index + k]])

# 		index += mem_size
	
func save_current_tree_state() -> void:
	var file := FileAccess.open(tree_state_path, FileAccess.WRITE)
	
	if not file:
		push_error("Couldn't open Tree State File", error_string(FileAccess.get_open_error()))
		return
	
	file.store_32(current_ID)

	for tree_node : TreeNode in get_node("TreeNodes").get_children():
		var packed := tree_node.ID | int(tree_node.locked) << 31
		
		prints("IS PACKED WORKING?", "ID", packed & 0x7FFFFFFF == tree_node.ID, "LOCKED", packed >> 31 & 1 == int(tree_node.locked))
		file.store_32(packed)

	file.close()
	

func load_current_tree_state() -> void:
	if not FileAccess.file_exists(tree_state_path):
		return
	
	var file := FileAccess.open(tree_state_path, FileAccess.READ)

	current_ID = file.get_32()

	while file.get_position() < file.get_length():
		var packed := file.get_32()

		var ID := packed & 0x7FFFFFFF
		var locked := packed >> 31 & 1
		
		ID_map[ID].locked = locked

	file.close()

func _exit_tree() -> void:
	save_current_tree_state()
