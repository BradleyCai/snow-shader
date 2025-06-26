extends SpringArm3D

@export var mouse_sens: float = 0.005

var mouse_escape: bool = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		mouse_escape = !mouse_escape

	if mouse_escape:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		return;
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if event is InputEventMouseMotion:
		get_parent().rotation.y -= event.relative.x * mouse_sens
		get_parent().rotation.y = wrapf(get_parent().rotation.y, 0.0, TAU)
		rotation.x -= event.relative.y * mouse_sens
		rotation.x = clamp(rotation.x, -TAU/4.01, TAU/8)