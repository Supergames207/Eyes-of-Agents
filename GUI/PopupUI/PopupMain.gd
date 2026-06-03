extends Control

signal new_label_added(label: Label)

var label_template: Label
var original_pos: Vector2

var label_tweens: Dictionary = {}
var label_targets: Dictionary = {} 

func _ready() -> void:
	label_template = $TemplateLabel
	self.new_label_added.connect(_on_new_label)

func _new_notification(text: String, color: Color) -> void:
	var label: Label = label_template.duplicate()
	add_child(label)
	
	label.name = "Notification"
	label.text = text
	label.remove_theme_color_override("font_color")
	label.add_theme_color_override("font_color", color)
	label.modulate.a = 0.0
	label.visible = true
	emit_signal("new_label_added", label)
	
	var tween_in: Tween = create_tween()
	tween_in.tween_property(label, "modulate:a", 1.0, .4) \
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_BACK)
	tween_in.play()
	await get_tree().create_timer(2.5).timeout
	
	var tween_out: Tween = create_tween()
	tween_out.tween_property(label, "modulate:a", 0.0, .4) \
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_BACK)
	tween_out.play()
	await tween_out.finished
	label.queue_free()

func _on_new_label(label: Label) -> void:
	for l in self.get_children():
		if l == label_template or l == label or not l.is_class("Label"): continue
		
		var current_target: float = label_targets.get(l, l.position.y)
		var new_target: float = current_target + label.size.y
		label_targets[l] = new_target
		
		if label_tweens.has(l) and label_tweens[l] != null:
			label_tweens[l].kill()
		
		var tween: Tween = create_tween()
		tween.tween_property(l, "position:y", new_target, .5)\
			.set_ease(Tween.EASE_IN)\
			.set_trans(Tween.TRANS_BACK)
		tween.play()
		
		label_tweens[l] = tween
