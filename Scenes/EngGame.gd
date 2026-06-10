extends Control


func close_eyes() -> void:
	var tween := get_tree().create_tween()
	tween.tween_method(process_close_eyes, 1.0, 0.0, 2.0)
	
func process_close_eyes(value : float) -> void:
	var rect : ColorRect = get_node("ColorRect")

	var mat : ShaderMaterial = rect.material

	mat.set_shader_parameter("open_factor", value)