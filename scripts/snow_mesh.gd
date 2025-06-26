extends MeshInstance3D

@export var _impact_back_renderer: Control

var _colliding_bodies: Dictionary[int, Node] = {}
var _impact_positions: PackedVector3Array # TODO add data info
var _num_impacts: int = 10

func _ready() -> void:
	assert(_impact_back_renderer != null, "snow mesh needs to have impact viewport set")

func _physics_process(_delta: float) -> void:
	_impact_positions.resize(_num_impacts)
	for i in range(_num_impacts):
		_impact_positions[i] = Vector3(0,0,0)

	var i := 0
	for body: PhysicsBody3D in _colliding_bodies.values():
		_impact_positions[i] = Vector3(body.global_position.x, 1.0, body.global_position.z)
		i += 1
	
	self._impact_back_renderer.material.set_shader_parameter("_impact_positions", _impact_positions)

func _on_area_3d_body_entered(body:Node3D) -> void:
	if body is not PhysicsBody3D:
		return
	_colliding_bodies[body.get_instance_id()] = body

func _on_area_3d_body_exited(body:Node3D) -> void:
	if body is not PhysicsBody3D:
		return

	_colliding_bodies.erase(body.get_instance_id())
