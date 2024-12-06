shader_type canvas_item;
uniform float frequency;
uniform float speed;
uniform float bandwith;
void vertex() {
	
	// Called for every vertex the material is visible on.
}

void fragment() {
	float dist = -UV.x + 0.35 * abs(UV.y - 0.5);
	float bands = sin(TIME * speed +  frequency * dist );
	
	bands = step(bandwith, bands);
	if(bands <= 0.0)
		COLOR.rgb = COLOR.rgb - vec3(0.1,0.1,0.1);
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}