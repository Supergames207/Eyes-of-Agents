@tool
class_name TreeNode extends Control


@export_tool_button("Organize Links") var organizor := organize_links
@export var links : Array[TreeNode]

@export var upgrades : Array[UpgradeInfo]

static var locked_texture : Texture2D = load("res://UpgradeTree/LockedTexture.tres")
static var may_unlock_texture : Texture2D = load("res://UpgradeTree/MayUnlockTexture.tres")
static var unlocked_texture : Texture2D = load("res://UpgradeTree/UnlockedTexture.tres")

const padding := Vector2(10,10)

var locked := true:
	set(value):
		if locked == value:
			return
		locked = value

		if not locked:
			for tree_node in links:
				tree_node.parents_unlocked += 1
		update_visuals()

var parents_unlocked := 0:
	set(value):
		parents_unlocked = value
		update_visuals()
var parents_count := 0

@export var ID : int = -1


func _ready() -> void:
	if Engine.is_editor_hint() and ID == -1:
		var parent : UpgradeTree = get_parent().get_parent()
		
		if parent.is_node_ready():
			create_ID()
		else:
			parent.ready.connect(create_ID, CONNECT_ONE_SHOT)

	for k in get_children():
		if k is Line2D:
			k.queue_free()
	
	create_connection_lines()
	update_visuals()

	for k in links:
		k.parents_count += 1

	mouse_entered.connect(mouse_state_changed.bind(true))
	mouse_exited.connect(mouse_state_changed.bind(false))


func create_ID() -> void:
	var parent : UpgradeTree = get_parent().get_parent()

	ID = parent.current_ID
	parent.current_ID += 1


func can_unlock() -> bool:
	assert(parents_unlocked >= 0 and parents_unlocked <= parents_count, "parents_unlocked OUT OF BOUND. ABORTING")

	return parents_unlocked == parents_count

func update_visuals() -> void: 
	if not is_node_ready() or Engine.is_editor_hint():
		return
	
	if locked == false:
		get_node("Background").texture = unlocked_texture
	elif can_unlock():
		get_node("Background").texture = may_unlock_texture
	else:
		get_node("Background").texture = locked_texture


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

		if event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
			unlock() #TODO Some logic to define if I can unlock this thingy

func unlock() -> void:
	if not can_unlock() or not locked:
		return
	
	locked = false

	for info in upgrades:
		GlobalPerkHolder.update_perk(info.perk_name, info.change, info.type)

	

func organize_links() -> void:
	for k in range(links.size()):
		links[k].global_position = global_position + Vector2(1, k - links.size() / 2.0 + 0.5) * (custom_minimum_size + padding)

func mouse_state_changed(entered : bool) -> void:
	get_node("InformationHolder").visible = entered
