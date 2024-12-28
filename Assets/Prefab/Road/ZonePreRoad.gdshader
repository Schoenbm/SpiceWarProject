shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR.rgb = vec3(0.5,0.75,1);
	float dist = distance(UV, vec2(0.5,0.5));
	float low_dist = smoothstep(0.49,0.495, dist);
	float far_dist = smoothstep(0.497, 0.5, dist);
	if (far_dist > 0.0)
		COLOR.a = (1.0 - far_dist) * COLOR.a;
	else if(low_dist > 0.0)
		COLOR.a = (0.2 + low_dist) * COLOR.a;
	else
		COLOR.a = 0.2 * COLOR.a;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
