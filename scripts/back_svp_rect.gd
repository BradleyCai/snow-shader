extends ColorRect

func _ready() -> void:
	var mat: ShaderMaterial = self.material
	var front_tex = mat.get_shader_parameter("_front_tex")
	mat.set_shader_parameter("_front_tex", null)
	await RenderingServer.frame_post_draw
	mat.set_shader_parameter("_front_tex", front_tex)