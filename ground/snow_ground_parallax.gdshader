shader_type spatial;

uniform vec4 _color: source_color;
uniform vec2 _tile = vec2(1.0, 1.0);
uniform vec2 _offset = vec2(0.0, 0.0);

// NOTE: for later
// instance uniform bool _show_impact = false;
uniform sampler2D _impact_map: hint_default_black;

uniform sampler2D _normalmap: hint_normal;

uniform float _mid_point: hint_range(0.0, 1.0) = 0.5;
uniform float _depth_scale: hint_range(0.0, 1.0) = 0.1;

varying vec2 transformedUV;

const float HEIGHT_CONSTANT_SCALE = 0.1;

void vertex() {
	transformedUV = UV * _tile + _offset;
}

float invLerp(float a, float b, float v) {
	return (v - a) / (b - a);
}

void fragment() {
	vec3 view_direction = normalize( -VERTEX + EYE_OFFSET ); // View direction in world space
	mat3 tbn =  mat3(-TANGENT, BINORMAL, NORMAL); // Tangent Binormal Normal matrix
	vec3 view_tangent_space = view_direction * tbn; // Transform view direction to tangent space
	float height = _mid_point - texture(_impact_map , transformedUV).x; // Sample the height map, invert
	vec2 uv_offset = view_tangent_space.xy * height * _depth_scale * HEIGHT_CONSTANT_SCALE; // Calculate the uv offset
	vec2 distorted_uv = transformedUV + uv_offset; // Add the offset to the original uv

	vec2 pixel_size = vec2(1.0, 1.0) / vec2(textureSize(_impact_map, 0));
	vec2 uv_tangent = distorted_uv + vec2(pixel_size.x, 0.0);
	vec2 uv_binormal = distorted_uv + vec2(0.0, pixel_size.y);
	vec4 impact = texture(_impact_map, distorted_uv);
	ALBEDO = _color.rgb;

	if (impact.rgb == vec3(1.0)) {
		NORMAL_MAP = texture(_normalmap, distorted_uv).xyz;
	} else {
		float f1 = texture(_impact_map, distorted_uv).r;
		float f2 = texture(_impact_map, uv_tangent).r;
		float f3 = texture(_impact_map, uv_binormal).r;

		vec3 tangent = normalize(vec3(1.0, 0.0, f2 - f1));
		vec3 binormal = normalize(vec3(0.0, 1.0, f3 - f1));
		float t = invLerp(-0.1, 1.0, impact.x); // TODO wtf lol
		vec3 avg = mix(normalize(cross(binormal, tangent)) * 0.5 + 0.5, texture(_normalmap, distorted_uv).xyz, t);
		NORMAL_MAP = avg;
		ALBEDO = mix(_color.rgb - 0.2, _color.rgb, impact.r);
	}
	ROUGHNESS = 0.5;
}
