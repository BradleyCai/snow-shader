extends Node3D

const _trees_packed_scenes: Array[Resource] = [
	preload("uid://doqhmfnafargi"),  # big_tree
	preload("uid://2urrp1gxblqm"),   # branch
	preload("uid://dmehole2dwufs"),  # tree 1
	preload("uid://dpqm0mkncw6li"),  # tree 2
	preload("uid://dnjdlhuxy0xvn"),  # tree 3
	preload("uid://b8d7tf5jo3cy2")   # stump
]

const _max_dist := 300.0
const _density := 10.0 # how many trees per 10x10 meters

func spawnTrees():
	for packedTree: PackedScene in _trees_packed_scenes:
		var num_trees = _max_dist / 10.0 * _density
		for i in range(num_trees):
			var tree = packedTree.instantiate()
			self.add_child(tree)
			tree.translate(Vector3(randf_range(-_max_dist, _max_dist), 0, randf_range(-_max_dist, _max_dist)))
			tree.rotate_y(randf_range(0, TAU))
			var tree_mesh = tree.get_child(0)
			if tree_mesh is GeometryInstance3D:
				tree_mesh.set_instance_shader_parameter("sway_seed", Vector2(randf_range(0, TAU), randf_range(0, TAU)))

func _ready() -> void:
	spawnTrees()
