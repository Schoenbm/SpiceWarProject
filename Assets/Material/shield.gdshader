shader_type canvas_item;
uniform sampler2D matrices_texture;
uniform sampler2D circle_texture;
uniform float blink_speed;
uniform bool charged = false;

uniform float fade_state = 0;
/* tout est visible a 0, invisible a 0.5*/
uniform bool hit = false;

uniform float blink_charged_amp = 0;
uniform float blink_charging_amp = 0.05;

uniform float blink_charged_base= 0.40;
uniform float blink_charging_base = 0.9;

uniform vec3 ring_color: source_color = vec3(1.0);
uniform float ring_frequency = 3.0;
/** Portion of the visible rings. Negative values give wider rings, positive values give narrower rings*/
uniform float ring_portion: hint_range(-0.9, 0.9, 0.1) = 0.0;
/** Negative values move the rings outwards, positive value move the rings inwards */
uniform float move_speed = -3.0;


void fragment() {
	vec2 uv_offset = vec2(UV.x + 0.01, UV.y - 0.035);
	vec4 circle_mask = texture(circle_texture, UV);
	vec4 matrices = texture(matrices_texture, uv_offset);
	float dist = distance(UV, vec2(0.5,0.5));
	float rings = sin(dist * ring_frequency + (TIME * move_speed));
	rings = step(ring_portion, rings);
	float blend_alpha = smoothstep(0.5, 0.4, dist);

	if(charged)
		COLOR.a = circle_mask.r * (blink_charged_amp * sin(TIME * blink_speed + 1.5)+ blink_charged_base + 0.4 * matrices.r);
	else{
		COLOR.a = circle_mask.r * (blink_charging_amp * sin(TIME * blink_speed + 1.5)+ blink_charging_base + 0.05 * matrices.r);
	}


	if (rings > 0.0)
		COLOR.a = COLOR.a + circle_mask.r * ((COLOR.a + 0.3) * 0.7 * matrices.r);
	if(hit)
		COLOR.a = circle_mask.r *  ( COLOR.a + 0.2);

	COLOR.a = COLOR.a * smoothstep(fade_state,fade_state * 1.2,dist);

	dist = smoothstep(0.51, 0.49,dist);
	COLOR.a = COLOR.a * dist;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
