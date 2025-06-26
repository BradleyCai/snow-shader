#[compute]
#version 450

// Invocations in the (x, y, z) dimension
layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

layout(rgba16f, set = 0, binding = 0) uniform image2D color_image;
layout(set = 0, binding = 1) uniform sampler2D depth_sampler;
// layout(set = 0, binding = 1) uniform readonly image2D depth_image;

// Our push constant
layout(push_constant, std430) uniform Params {
	vec2 raster_size;
	vec2 reserved; // read post_process_grayscale.gd for more information on this
} params;

// The code we want to execute in each invocation
void main() {
	ivec2 screen_coord = ivec2(gl_GlobalInvocationID.xy);
	ivec2 size = ivec2(params.raster_size);

	// Prevent reading/writing out of bounds.
	if (screen_coord.x >= size.x || screen_coord.y >= size.y) {
		return;
	}

	ivec2 screen_coord_flip_h = ivec2(size.x - screen_coord.x - 1, screen_coord.y);
	vec2 uv_flip_h = vec2(screen_coord_flip_h) / vec2(size);

	float depth = texture(depth_sampler, uv_flip_h).x;
	
	if (depth != 0.0) {
		depth = 1.0 - depth;
	}

	// Write back to our color buffer.
	imageStore(color_image, screen_coord, vec4(depth, 0.0, 0.0, 1.0));
}
