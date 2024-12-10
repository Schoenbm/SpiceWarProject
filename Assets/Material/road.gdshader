shader_type canvas_item;


uniform vec3 color_begin;
uniform vec3 color_end;
uniform vec3 temp_begin_color;
uniform vec3 temp_end_color;
uniform float transition_time;
uniform float transition_end_time;

uniform float frequency;
uniform float speed;
uniform float bandwith;

uniform bool wobble;
uniform float wobble_speed;
uniform float merge_zone_half_width : hint_range(0,0.5);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float dist = UV.x;
	float bands;

	if(wobble){
		bands = sin(sin(TIME * wobble_speed) * speed +  frequency * dist );
	}
	else{
		bands = sin(TIME * speed +  frequency * dist );
	}

	bands = step(bandwith, bands);

	float begin_color_coef;
	float end_color_coef;

	if(bands > 0.0)
		COLOR.a = 0.0;
	else
		COLOR.a = 0.9;


	begin_color_coef = smoothstep(0.5 + merge_zone_half_width, 0.5 - merge_zone_half_width,dist);
	end_color_coef = smoothstep(0.5 - merge_zone_half_width, 0.5 + merge_zone_half_width,dist);

	if(0.5-abs(dist-0.5) > transition_time/ (2.0 * transition_end_time) ){
		COLOR.rgb = begin_color_coef * color_begin + end_color_coef * color_end + vec3(0.25,0.25,0.25);
	}
	else
		COLOR.rgb = begin_color_coef * temp_begin_color + end_color_coef * temp_end_color + vec3(0.25,0.25,0.25);


}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
