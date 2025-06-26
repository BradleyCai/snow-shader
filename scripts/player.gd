extends CharacterBody3D

# How fast the player moves in meters per second.
@export var speed = 10
# The downward acceleration when in the air, in meters per second squared.
@export var fall_acceleration = 20
@export var pivot: Node3D
@export var viewer: Node3D
@export var jump_amount: float = 200

var target_velocity = Vector3.ZERO
var acceleration = Vector3.ZERO

func get_sibling(node_path: String):
	return self.get_parent().find_child(node_path, false)

func _ready() -> void:
	if viewer == null:
		assert(false, "A default viewer (camera or whatever is looking at the player) was not found")

func _push_away_rigid_bodies():
	for i in get_slide_collision_count():
		var c := get_slide_collision(i)
		if c.get_collider() is RigidBody3D:
			var push_dir = -c.get_normal()
			# How much velocity the object needs to increase to match player velocity in the push direction
			var velocity_diff_in_push_dir = self.velocity.dot(push_dir) - c.get_collider().linear_velocity.dot(push_dir)
			# Only count velocity towards push dir, away from character
			velocity_diff_in_push_dir = max(0., velocity_diff_in_push_dir)
			# Objects with more mass than us should be harder to push. But doesn't really make sense to push faster than we are going
			const MY_APPROX_MASS_KG = 80.0
			var mass_ratio = min(1., MY_APPROX_MASS_KG / c.get_collider().mass)
			# Optional add: Don't push object at all if it's 4x heavier or more
			if mass_ratio < 0.25:
				continue
			# Don't push object from above/below
			push_dir.y = 0
			# 5.0 is a magic number, adjust to your needs
			var push_force = mass_ratio * 5.0
			c.get_collider().apply_impulse(push_dir * velocity_diff_in_push_dir * push_force, c.get_position() - c.get_collider().global_position)

func _physics_process(delta):
	var player_sideways_dir = self.up_direction.cross(self.transform.basis.z)
	var player_forward_dir = player_sideways_dir.cross(self.up_direction)

	var direction = Vector3.ZERO
	if Input.is_action_pressed("move_right"):
		direction += -player_sideways_dir
	if Input.is_action_pressed("move_left"):
		direction += player_sideways_dir
	if Input.is_action_pressed("move_back"):
		direction += -player_forward_dir
	if Input.is_action_pressed("move_forward"):
		direction += player_forward_dir

	# readjust rotation when moving
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		pivot.basis = Basis.looking_at(direction)

	# Ground Velocity
	target_velocity = direction * speed

	target_velocity += acceleration * delta
	if is_on_floor():
		acceleration = Vector3.ZERO
		if Input.is_action_pressed("jump"):
			acceleration = jump_amount * self.up_direction
	else:
		acceleration = acceleration + (fall_acceleration * -self.up_direction)

	# Moving the Character
	self.velocity = target_velocity
	_push_away_rigid_bodies()
	move_and_slide()
