shader_type canvas_item;

uniform float total_time;
uniform float time;


void fragment() {
	float dist = distance(UV,vec2(0.5,0.5));
	vec2 direction = UV - vec2(0.5,0.5);
	direction = normalize(direction);
	vec2 up = vec2(0.0,1.0);
	float angle = (atan(direction.x, direction.y) + PI) / (2.0 * PI);
	angle = smoothstep(angle * 0.9, angle * 1.0, time/total_time);
	
	COLOR.rgb = COLOR.rgb - (COLOR.rgb * angle / 2.0);
	
	
}

