shader_type canvas_item;

uniform float open_factor;

void vertex() {
}

void fragment() {
	COLOR = vec4(1);
	
	vec2 sheared_uv = UV - 0.5;
	vec2 basis = vec2(0.4 - 0.4/(open_factor * 10.) + 0.6, 0.0);
	basis.x = max(0.7, basis.x);
	sheared_uv = sheared_uv.x * basis + vec2(0, sheared_uv.y);
	sheared_uv += 0.5;
	
	if (distance(sheared_uv, vec2(0.5, 1.0 - open_factor)) < 0.5 && UV.y < 0.5){
		COLOR.rgb *= distance(sheared_uv, vec2(0.5, 1.0 - open_factor));
	}
	
	if (distance(sheared_uv, vec2(0.5, open_factor)) < 0.5 && UV.y > 0.5){
		COLOR.rgb *= distance(sheared_uv, vec2(0.5, open_factor));
	}
	
	if (sheared_uv.y < open_factor && sheared_uv.y > 0.5){
		COLOR.rgb *= 0.;
	}
	if (sheared_uv.y > 1.0 - open_factor && sheared_uv.y < 0.5){
		COLOR.rgb *= 0.;
	}
	
	COLOR.rgb = vec3(1) - COLOR.rgb;
	COLOR.a = 1.0 - length(COLOR.rgb);
	//COLOR.rgb *= distance(UV, vec2(0.5, slider));
	
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
