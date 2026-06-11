shader_type spatial;
render_mode unshaded;

uniform sampler2D shape_texture: source_color, repeat_disable;

void fragment() {
	vec4 shape = texture(shape_texture, UV);
	
	ALBEDO = shape.rgb;
	ALPHA = 0.95;//shape.a * diff * y_fade;
}
