extends ColorRect

func _ready() -> void:
	var mat: ShaderMaterial = self.material
	var back_tex = mat.get_shader_parameter("back_tex")
	mat.set_shader_parameter("back_tex", null)
	await RenderingServer.frame_post_draw
	mat.set_shader_parameter("back_tex", back_tex)