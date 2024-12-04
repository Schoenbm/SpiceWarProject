shader_type canvas_item;
uniform float red;
uniform float blue;
uniform float green;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	//COLOR.rgb = vec3(red,blue,green);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
