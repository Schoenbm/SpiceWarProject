shader_type canvas_item;


uniform vec3 color_begin;
uniform vec3 color_end;

uniform float frequency;
uniform float speed;
uniform float bandwith;

uniform float merge_zone_half_width : hint_range(0,0.5);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float dist = UV.x;
	float bands = sin(TIME * speed +  frequency * dist );
	
	bands = step(bandwith, bands);
	if(bands > 0.0)
		COLOR.a = 0.0;
	
	float begin_color_coef = smoothstep(0.5 + merge_zone_half_width, 0.5 - merge_zone_half_width,dist);
	float end_color_coef = smoothstep(0.5 - merge_zone_half_width, 0.5 + merge_zone_half_width,dist);
	
	COLOR.rgb = begin_color_coef * color_begin + end_color_coef * color_end + vec3(0.25,0.25,0.25);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
