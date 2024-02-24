shader_type canvas_item;

uniform vec4 color : source_color = vec4(1.0);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float alpha =  1.0 - float(UV.x > 0.1  && UV.x < 3.4 && UV.y > 0.1 && UV.y < 3.4);
	COLOR = color;
	COLOR.a = alpha;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
