shader_type spatial;
render_mode blend_add, cull_disabled, unshaded, depth_draw_never;

uniform vec4 _start_color: source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform vec4 _end_color: source_color = vec4(1.0, 1.0, 0.0, 0.0);
uniform float _end_pos: hint_range(0.0, 1.0) = 0.5;

void vertex() {
}

float invLerp(float a, float b, float v) {
	return (v - a) / (b - a);
}

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
	float end_pos = _end_pos;// + random(vec2(TIME, 0.0)) * 0.05 + sin(TIME * 40.0) * 0.02;
	float t = clamp(invLerp(0.0, end_pos + sin(UV.x * 100.0 + TIME * TAU * 2.0) * 0.01, UV.y), 0.0, 1.0);
	vec4 color = mix(_start_color, _end_color, t);
	ALBEDO = vec3(color.rgb);
	//NORMAL = normalize(NORMAL);
	ALPHA = color.a;
}
