shader_type canvas_item;
uniform sampler2D deeper_space : filter_linear_mipmap,repeat_enable;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 noise = texture(deeper_space,UV + 0.005 * TIME);
	COLOR.rgb = COLOR.rgb;

	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
