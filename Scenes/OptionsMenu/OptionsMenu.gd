@tool
class_name OptionsMenu extends BaseMenu

@export_tool_button("Test Create Menu") var tester := create_menu

func create_menu() -> void:
	var title := get_node("PanelContainer/HBoxContainer/Title")
	var slider := get_node("PanelContainer/HBoxContainer/Slider")
	var value := get_node("PanelContainer/HBoxContainer/Value")

	for k in title.get_children():
		k.queue_free()
	for k in slider.get_children():
		k.queue_free()
	for k in value.get_children():
		k.queue_free()

	for preference_name in GlobalPreferences.preferences:
		var title_label := Label.new()
		var new_slider := HSlider.new()
		var value_label := Label.new()

		title_label.text = preference_name

		var preference_data := GlobalPreferences.preferences[preference_name]

		new_slider.min_value = preference_data.number_range.start
		new_slider.max_value = preference_data.number_range.end
		new_slider.value = preference_data.value

		title.add_child(title_label)
		slider.add_child(new_slider)
		value.add_child(value_label)

		title_label.owner = self
		new_slider.owner = self
		value_label.owner = self
