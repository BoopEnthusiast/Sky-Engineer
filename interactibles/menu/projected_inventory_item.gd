class_name ProjectedMenuItem
extends Node3D


@export_range(0.0, 10.0) var z_depth: float = 5.0
@export var counterpart_in_2d: Control
## The reference camera of the scene
@export var reference_camera: Camera3D

@export_group("Slow turn to camera")
## If this is enabled, it assumes it's not a child of Menu3D and has a RemoteTransform3D in its place[br]
## [br]
## If you have this off, just put this node as a child of Menu3D
@export var turn_to_camera: bool = false
## When turn_to_camera is enabled, this must be set to a child of Menu3D and this node must be a child of Menu and not Menu3D[br]
## [br]
## What's supposed to happen is that you have a RemoteTransform3D with rotation turned off as a child of Menu3D.
## Then, you enable turn_to_camera and this node will slowly turn toward the camera
@export var remote_transform: RemoteTransform3D
## The lerp speed it rotates to the camera. By default it's a quarter of Menu.LERP_SPEED
@export_range(0.5, 10.0) var turn_lerp_speed: float = Menu.LERP_SPEED / 4


func _process(delta: float) -> void:
	# Project the position it needs to move to from the reference camera.
	# This means it'll be relative to Vector3.ZERO, which is what we need
	# because it is moving the position of the node and not the global_position.
	# The Menu3D is already moving in front of the main camera so that
	# global position work is already done for us.
	var position_to_move_to = reference_camera.project_position(counterpart_in_2d.global_position, z_depth)
	
	if not turn_to_camera:
		# Move to the screen position of the control node counterpoint
		position = position_to_move_to
		return
	
	# Move remote transform to the screen position of the control node counterpoint
	remote_transform.position = position_to_move_to
	
	# Get the basis it needs to slerp to
	var viewport = get_viewport()
	var main_camera = get_viewport().get_camera_3d()
	var new_basis = Basis.looking_at(global_position - main_camera.global_position)
	# Turn the y basis to face upwards in accordance with the main camera's center and not where this node is
	# You can comment out these three lines and see what happens when you look up and down if you're curious
	var looking_at_position = main_camera.project_position(viewport.get_visible_rect().size / 2, z_depth)
	var main_camera_basis = Basis.looking_at(looking_at_position - main_camera.global_position)
	new_basis = new_basis.rotated(new_basis.z, new_basis.y.signed_angle_to(main_camera_basis.y, new_basis.z)).orthonormalized()
	# Get the weight for slerping it (love that word lmao)
	var weight = 1 - exp(-turn_lerp_speed * delta) # Makes it framerate-independent like it says in:
	# https://docs.godotengine.org/en/stable/tutorials/math/interpolation.html#smoothing-motion
	global_basis = global_basis.slerp(new_basis, weight)
