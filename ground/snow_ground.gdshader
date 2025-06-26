shader_type spatial;

uniform vec4 _color: source_color;
uniform vec2 _tile = vec2(1.0, 1.0);
uniform vec2 _offset = vec2(0.0, 0.0);

// NOTE: for later
// instance uniform bool _show_impact = false;
uniform sampler2D _impact_map: hint_default_black;

uniform sampler2D _normalmap: hint_normal;

uniform sampler2D _displacement_map: hint_default_black;
uniform float _displacement_intensity: hint_range(0, 1.0) = 0.1;
uniform float _displacement_scale: hint_range(0, 6.0) = 0.1;

varying vec2 transformedUV;

void vertex() {
	transformedUV = UV * _tile + _offset;
	//float displacement = texture(_impact_map, UV).x;
	//VERTEX = VERTEX + vec3(0.0, displacement * _displacement_intensity, 0.0);
}

float invLerp(float a, float b, float v) {
	return (v - a) / (b - a);
}

void fragment() {
	vec2 pixel_size = vec2(1.0, 1.0) / vec2(textureSize(_impact_map, 0));
	vec2 uv_tangent = UV + vec2(pixel_size.x, 0.0);
	vec2 uv_binormal = UV + vec2(0.0, pixel_size.y);
	vec4 impact = texture(_impact_map, transformedUV);
	//ALBEDO = _color.rgb - (1.0 - impact.x) / 4.0;
	ALBEDO = _color.rgb - 0.2;

	if (impact.rgb == vec3(1.0)) {
		NORMAL_MAP = texture(_normalmap, transformedUV).xyz;
	} else {
		float f1 = texture(_impact_map, UV).r;
		float f2 = texture(_impact_map, uv_tangent).r;
		float f3 = texture(_impact_map, uv_binormal).r;

		vec3 tangent = normalize(vec3(1.0, 0.0, f2 - f1));
		vec3 binormal = normalize(vec3(0.0, 1.0, f3 - f1));
		vec3 avg = mix(normalize(cross(binormal, tangent)) * 2.0 + 0.5, texture(_normalmap, transformedUV).xyz, impact.x);
		NORMAL_MAP = avg;
		ALBEDO = mix(_color.rgb - 0.25, _color.rgb - 0.2, impact.r);
	}
	ROUGHNESS = 0.6;
}
