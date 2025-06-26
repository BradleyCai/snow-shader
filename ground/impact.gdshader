shader_type canvas_item;

uniform sampler2D _front_tex: hint_default_white;
uniform sampler2D _below_actors_tex: hint_default_white;
uniform sampler2D _surface_depth_tex: hint_default_white;

const vec3 WHITE = vec3(1.0);
const vec3 BLACK = vec3(0.0);

varying vec2 pixel_size;

void vertex() {
	pixel_size = vec2(1.0, 1.0) / vec2(textureSize(_front_tex, 0));
}

float invLerp(float a, float b, float v) {
	return (v - a) / (b - a);
}

float invLerp01(float a, float b, float v) {
	return clamp(invLerp(a, b, v), 0.0, 1.0);
}

void fragment() {
	vec4 prev_color = texture(_front_tex, UV);
	//COLOR = clamp(prev_color + _decay, vec4(BLACK, 1.0), vec4(WHITE, 1.0));

	vec2 origin = vec2(0.0, 0.0);
	float max_dist = 4.0; // TODO: dont set manually

	float below_actor_height = texture(_below_actors_tex, UV).r;
	float surface_height = texture(_surface_depth_tex, UV).r;
	float top_surface_height = surface_height + 0.5/max_dist;

	//if (prev_color.rgb == WHITE) { // crazy effect
	float north = texture(_front_tex, UV - vec2(0.0, pixel_size.y)).r;
	float east = texture(_front_tex, UV + vec2(pixel_size.x, 0.0)).r;
	float south = texture(_front_tex, UV + vec2(0.0, pixel_size.y)).r;
	float west = texture(_front_tex, UV - vec2(pixel_size.x, 0.0)).r;

	float neighbor_avg = (north + east + south + west) / 4.0;
	if (neighbor_avg < 0.95) {
		COLOR = vec4(vec3(neighbor_avg + 0.003), 1.0);
	}

	float diff = abs(below_actor_height - surface_height);
	if (diff < 0.01) {
		//float t = invLerp01(surface_height + 0.03, surface_height + 0.05, below_actor_height);
		vec3 _impact_color = BLACK; //vec3(mix(BLACK, WHITE, t)); // TODO: figure out edge issue
		//COLOR = vec4(_impact_color.r - COLOR.r > 0.005 ? COLOR.rgb : _impact_color, 1.0); // blend
		COLOR = vec4(_impact_color, 1.0);
	}
}
