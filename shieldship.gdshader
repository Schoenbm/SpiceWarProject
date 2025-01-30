shader_type canvas_item;
uniform sampler2D matrices_texture;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 uv;
	uv.x = fract(UV.x + TIME * 0.3);
	vec4 matrices = texture(matrices_texture, uv);
	if(matrices.r >= 0.8){
		COLOR.rg = COLOR.rg * (0.5);
		COLOR.b = COLOR.b * (0.8);
	}

}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
