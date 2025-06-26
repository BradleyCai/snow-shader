shader_type spatial;

void vertex() {
	VERTEX = VERTEX + vec3(sin(TIME * TAU * 0.5 + -VERTEX.y * 100.0) * 0.1 * -VERTEX.y, 0.0, 0.0);
}

void fragment() {
	// Called for every pixel the material is visible on.
}