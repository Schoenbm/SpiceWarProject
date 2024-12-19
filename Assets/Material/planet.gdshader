shader_type canvas_item;

uniform vec3 previous_color;
uniform vec3 color;

uniform float transition_time;
uniform float transition_duration;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	//if((transition_time / (2.0 *transition_duration)) > 0.51 - distance(UV,vec2(0.5,0.5)))
		//COLOR.rgb =  previous_color;
	//else{
	COLOR.rgb = color;
	//}

	float dist = distance(UV, vec2(0.5,0.5));
	dist = smoothstep(0.51, 0.48,dist);
	COLOR.a = COLOR.a * dist;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
