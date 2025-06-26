@tool
extends MeshInstance3D

func _ready() -> void:
	if Engine.is_editor_hint():
		self.visible = false
	else:
		self.visible = true
	