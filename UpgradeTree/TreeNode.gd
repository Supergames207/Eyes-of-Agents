@tool
class_name TreeNode extends Control


@export_tool_button("Organize Links") var organizor := organize_links
@export var links : Array[TreeNode]

@export var upgrades : Array[UpgradeInfo]

@export var cost : int
@export var node_name : String
@export var icon : Texture2D:
	set(value):
		icon = value

		if is_node_ready():
			get_node("Icon").texture = icon

@export var max_unlocked_links := -1
@export var min_parents_unlocked := -1

const padding := Vector2(15, 15)
const lines_colour := Color(106 / 255., 106 / 255., 106 / 255., 1)

static var locked_texture : Texture2D = load("res://UpgradeTree/LockedTexture.tres")
static var may_unlock_texture : Texture2D = load("res://UpgradeTree/MayUnlockTexture.tres")
static var unlocked_texture : Texture2D = load("res://UpgradeTree/UnlockedTexture.tres")

signal unlocked


var locked := true:
	set(value):
		if locked == value:
			return
		locked = value

		if not locked:
			for tree_node in links:
				tree_node.parents_unlocked += 1

			unlocked.emit()
		update_visuals()

var parents_unlocked := 0:
	set(value):
		parents_unlocked = value
		update_visuals()
var parents_count := 0:
	set(value):
		parents_count = value
		update_visuals()

var unlocked_links := 0

var can_unlock_enforcer := true

@export var ID : int = -1:
	set(value):
		ID = value
		if Engine.is_editor_hint() and ID == -1:
			var parent : UpgradeTree = get_parent().get_parent()
			
			if parent.is_node_ready():
				create_ID()
			else:
				parent.ready.connect(create_ID, CONNECT_ONE_SHOT)


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
	
	get_node("Sphere/Icon").texture = icon
	
	create_connection_lines()
	update_visuals()
	create_information_text()

	for k in links:
		k.parents_count += 1

		if k.locked == false:
			link_unlocked()
		else:
			k.unlocked.connect(link_unlocked, CONNECT_ONE_SHOT)

	mouse_entered.connect(mouse_state_changed.bind(true))
	mouse_exited.connect(mouse_state_changed.bind(false))


func create_ID() -> void:
	var parent : UpgradeTree = get_parent().get_parent()

	ID = parent.current_ID
	parent.current_ID += 1


func can_unlock() -> bool:
	assert(parents_unlocked >= 0 and parents_unlocked <= parents_count, "parents_unlocked OUT OF BOUND. ABORTING")

	return (parents_unlocked == parents_count or (min_parents_unlocked != -1 and min_parents_unlocked <= parents_unlocked)) \
			and can_unlock_enforcer

func update_visuals() -> void: 
	if not is_node_ready() or Engine.is_editor_hint():
		return
	
	if locked == false:
		get_node("Sphere/Background").texture = unlocked_texture
	elif can_unlock():
		get_node("Sphere/Background").texture = may_unlock_texture
	else:
		get_node("Sphere/Background").texture = locked_texture


func create_connection_lines() -> void:
	if not is_node_ready():
		return
	
	for tree_node in links:
		var new_x := Line2D.new()
		new_x.position = Vector2(size.x, size.y / 2.0)

		new_x.default_color = lines_colour
		new_x.z_index = -1

		add_child(new_x)
		new_x.owner = owner

		var target_position := Vector2(tree_node.global_position.x + size.x / 2.0, new_x.global_position.y) #+ Vector2(0, size.y / 2.0))
		
		new_x.add_point(Vector2.ZERO)
		new_x.add_point(target_position - new_x.global_position)

		
		target_position = (tree_node.global_position + Vector2(size.x / 2.0, size.y / 2.0))
		
		new_x.add_point(target_position - new_x.global_position)

		
	

func _gui_input(e : InputEvent) -> void:
	if e is InputEventMouseButton:
		var event : InputEventMouseButton = e

		if event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
			unlock() #TODO Some logic to define if I can unlock this thingy

func unlock() -> void:
	if not can_unlock() or not locked:
		AudioManager.play("res://Sounds/Pack2/GUI Sound Effects_063.wav", 1.0, 1.05, -10.)
		
		return
	
	locked = false

	AudioManager.play("res://Sounds/Pack2/GUI Sound Effects_061.wav", 1.0, 1.05, -10.)

	GlobalVariables.player.adjacent_money_losses += cost

	for info in upgrades:
		GlobalPerkHolder.update_perk(info.perk_name, info.change, info.type)
		prints(info.perk_name, "NEW", GlobalPerkHolder.get_perk_value(info.perk_name))

	
func link_unlocked() -> void:
	unlocked_links += 1

	assert(unlocked_links <= max_unlocked_links or max_unlocked_links == -1)

	if unlocked_links == max_unlocked_links:
		for link in links:
			if not link.locked:
				continue
			
			link.can_unlock_enforcer = false


func organize_links() -> void:
	for k in range(links.size()):
		links[k].global_position = global_position + Vector2(1, k - links.size() / 2.0 + 0.5) * (custom_minimum_size + padding)

func mouse_state_changed(entered : bool) -> void:
	get_node("Sphere/InformationHolder").visible = entered

	var tween := get_tree().create_tween()

	if entered:
		tween.tween_property(get_node("Sphere"), "scale", Vector2(1.1, 1.1), 0.25)
		# create_information_text()
	else:
		tween.tween_property(get_node("Sphere"), "scale", Vector2(1,1), 0.25)
	# else: #This was making the text look weird after the mouse enters the UI a second time
		# get_node("Sphere/InformationHolder/Information").text = ""


func generate_upgrade_text(upgrade : UpgradeInfo) -> String:
	match upgrade.type:
		PerkHolder.UpdateType.Add:
			var change_sign := "Increases " if signf(upgrade.change) else "Decreases "
			return change_sign + str(upgrade.perk_name) + " by " + str(abs(upgrade.change))
		
		PerkHolder.UpdateType.BaseMultiply:
			return "Increments " + str(upgrade.perk_name) + " by " + str(abs(upgrade.change) * 100) + "%" 
		
		PerkHolder.UpdateType.Add:
			return "Multiplies " + str(upgrade.perk_name) + " by " + str(upgrade.change) 

		_:
			return ""

func create_information_text() -> void:
	var text : String = node_name + "\nCost :" + str(cost) + "$ \n"

	for up in upgrades:
		text += generate_upgrade_text(up) + "\n"

	get_node("Sphere/InformationHolder/Information").text = text
