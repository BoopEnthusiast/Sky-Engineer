class_name ProjectedInventoryItem
extends Node3D


@export_range(0.0, 10.0) var z_depth: float = 5.0
@export var counterpart_in_2d: Control
## The reference camera of the scene
@export var reference_camera: Camera3D
@export_group("Slow turn to camera")
## If this is enabled, it assumes it's not a child of Inventory3D and has a RemoteTransform3D in its place[br]
## [br]
## If you have this off, just put this node as a child of Inventory3D
@export var turn_to_camera: bool = false
## When turn_to_camera is enabled, this must be set to a child of Inventory3D and this node must be a child of Inventory and not Inventory3D[br]
## [br]
## What's supposed to happen is that you have a RemoteTransform3D with rotation turned off as a child of Inventory3D.
## Then, you enable turn_to_camera and this node will slowly turn toward the camera
@export var remote_transform: RemoteTransform3D
## The lerp speed it rotates to the camera. By default it's half of Inventory.LERP_SPEED
@export_range(0.5, 10.0) var lerp_speed: float = Inventory.LERP_SPEED / 2


func _process(delta: float) -> void:
	var position_to_move_to = reference_camera.project_position(counterpart_in_2d.global_position, z_depth)
	
	if turn_to_camera:
		# Move remote transform to the screen position of the control node counterpoint
		remote_transform.position = position_to_move_to
		
		var weight = 1 - exp(-lerp_speed * delta) # Makes it framerate-dependent like it says in:
		# https://docs.godotengine.org/en/stable/tutorials/math/interpolation.html#smoothing-motion
		var main_camera = get_viewport().get_camera_3d()
		global_basis = global_basis.slerp(Basis.looking_at(global_position - main_camera.global_position), weight / 2)
	else:
		# Move to the screen position of the control node counterpoint
		position = position_to_move_to
