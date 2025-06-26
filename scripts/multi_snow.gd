@tool
extends MultiMeshInstance3D

@export_tool_button("Generate Tiled Snow", "Callable") var generate_action = generateTiledSnow

@export var _size = 2

func hello():
	print("Hello world!")

func generateTiledSnow():
	if multimesh.mesh is not PrimitiveMesh:
		push_error("This script expects a primitive mesh to be used in the multi mesh")

	multimesh.instance_count = _size * _size 

	var mesh_size: Vector2 = multimesh.mesh.size
	var start_pos_xy: Vector2 = -mesh_size / 2.0 * (_size - 1.0)
	var start_pos: Vector3 = Vector3(start_pos_xy.x, 0.0, start_pos_xy.y)
	for x in range(_size):
		for z in range(_size):
			var tile_id = x + z * _size
			var tile_pos = start_pos + Vector3(x * mesh_size.x, 0.0, z * mesh_size.y)
			self.multimesh.set_instance_transform(tile_id, Transform3D(Basis.IDENTITY, tile_pos))
