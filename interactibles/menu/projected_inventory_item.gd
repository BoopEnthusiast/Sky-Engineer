class_name ProjectedMenuItem
extends Node3D
## A node that'll try to stay projected in front of the main camera.
## 
## This [Node3D] offshoot will always be projected in front of [method Node.get_viewport].[method Viewport.get_camera_3d].[br]
## It has some other cool features, too.[br]
## [br]
## It's designed to work in the [Menu] scene, interacting with Menu3D and Menu2D.


## How far from the camera you want this node to be projected.
@export_range(0.0, 10.0) var z_depth: float = 5.0
## The counterpart [Control] node in 2D.[br]
## You should set the [Control] node to have a size of [constant Vector2.ZERO] and [member Control.mouse_filter] should be [constant Control.MOUSE_FILTER_IGNORE].[br]
## Place the [Control] node where you want this node to appear relative to the main camera.
@export var counterpart_in_2d: Control

@export_group("Not A Child Of Menu3D")
## When [member turn_to_camera] or [member follow_mouse] is enabled, this must be set to a child of Menu3D and this node must be a child of Menu and not Menu3D.[br]
## [br]
## You do not need to set this if neither [member turn_to_camera] nor [member follow_mouse] are enabled.[br]
## [br]
## What's supposed to happen is that you have a [RemoteTransform3D] with [member RemoteTransform3D.update_rotation] turned off as a child of Menu3D, 
## and [member RemoteTransform.update_position] if [member follow_mouse] is enabled.[br]
## Then, you enable [member turn_to_camera] and this node will slowly turn toward the camera.
## And/or, you enable [member follow_mouse] and this node will only move when it leaves the bounds of the [member counterpart_in_2d].
@export var remote_transform: RemoteTransform3D

@export_subgroup("Turn To Camera")
## If this is enabled, it assumes it's not a child of Menu3D and has a [RemoteTransform3D] in its place.[br]
## [br]
## If you have this off, just put this node as a child of Menu3D.[br]
## [br]
## If this is on, make sure the [member remote_transform]'s [member RemoteTransform3D.update_rotation] is disabled.[br]
## [br]
## If [member follow_mouse] is also turned on, it won't turn until the player is looking outside of the area.
## If this is the case, you should probably increase [member turn_slerp_speed] to match or be higher than [member lerp_speed].
@export var turn_to_camera: bool = false
## The slerp speed it rotates to the main camera. By default it's a quarter of [constant Menu.LERP_SPEED].
@export_range(0.5, 10.0) var turn_slerp_speed: float = Menu.LERP_SPEED / 4

@export_subgroup("Follow Mouse Boundary")
## If this is enabled, give the 2D counterpart a size relative to how far away from the center of
## this node you want the camera to turn before this node follows it. Also, give it a [member collsion_area]
## with a [CollsionShape2D] as a child, with a [RectangleShape2D] as its [member CollisionShape2D.shape][br]
## [br]
## This node will be at the center of the 2D counterpart before the camera moves.[br]
## [br]
## If this is on, make sure the [member remote_transform]'s [member RemoteTransform3D.update_position] is disabled.
@export var follow_mouse: bool = false
## If [member follow_mouse] is enabled, set this to an [Area2D] child of [member counterpart_in_2d] with with a [RectangleShape2D] as its [CollsionShape2D]'s [member CollisionShape2D.shape][br]
## [br]
## The actual shape of the [CollsionShape2D] is set to be the same as [member counterpart_in_2d] so no need to change its size or move it or anything.
## In fact, do not move it.[br]
## [br]
## Also, put the [Area2D] on its own collsion layer. This will be copied over to the scene's [RayCast2D] when checking collision.
@export var collision_area: Area2D
## The lerp speed it moves to the projected point from the main camera. By default it's the same as [constant Menu.LERP_SPEED].
@export_range(0.5, 10.0) var lerp_speed: float = Menu.LERP_SPEED

var debug_line_1: Debug3DLine
var debug_line_2: Debug3DLine
var debug_line_3: Debug3DLine
var debug_line_4: Debug3DLine
var debug_line_5: Debug3DLine
var debug_line_6: Debug3DLine
var debug_line_7: Debug3DLine
var debug_line_8: Debug3DLine
var debug_line_9: Debug3DLine


func _ready() -> void:
	debug_line_1 = Debug.create_3d_line([], Color.RED)
	debug_line_2 = Debug.create_3d_line([], Color.GREEN)
	debug_line_3 = Debug.create_3d_line([], Color.BLUE)
	debug_line_4 = Debug.create_3d_line([], Color.CYAN)
	debug_line_5 = Debug.create_3d_line([], Color.YELLOW)
	debug_line_6 = Debug.create_3d_line([], Color.MAGENTA)
	debug_line_7 = Debug.create_3d_line([], Color.TEAL)
	debug_line_8 = Debug.create_3d_line([], Color.ORANGE)
	debug_line_9 = Debug.create_3d_line([], Color.PURPLE)


func _process(delta: float) -> void:
	_handle_rotation(delta, _handle_position(delta))


## Moves the global position to the remote transform's global position.[br]
## [br]
## This is useful if you have follow_mouse turned on and want this node hidden most of the time,
## but to appear at the center of the screen when you make it visible.
func move_to_remote_transform() -> void:
	global_position = remote_transform.global_position


# Returns true if follow_mouse is enabled and it is outside the area
func _handle_position(delta: float) -> Vector3:
	# Project the position it needs to move to from the reference camera.
	# This means it'll be relative to Vector3.ZERO, which is what we need
	# because it is moving the position of the node and not the global_position.
	# The Menu3D is already moving in front of the main camera so that global
	# position work is already done for us.
	var counterpart_in_2d_rect := counterpart_in_2d.get_rect()
	var center_of_2d_counterpart: Vector2 = counterpart_in_2d_rect.position + counterpart_in_2d_rect.size / 2
	var position_to_move_to := Nodes.menu.reference_camera.project_position(center_of_2d_counterpart, z_depth)
	
	if turn_to_camera or follow_mouse:
		# Move remote transform to the screen position of the center of the control node counterpoint
		remote_transform.position = position_to_move_to
	else:
		# Move to the screen position of the center of the control node counterpoint
		position = position_to_move_to
	
	# After this is all the stuff for follow_mouse
	if not follow_mouse:
		return Vector3.ZERO
	
	# Get the main camera since it'll be used multiple times
	var main_camera = get_viewport().get_camera_3d()
	
	# Get the unprojected position and weight, this is here because they'll be used no matter what happens
	# If any of the conditions for lerping to the edge of the area are false, it'll still lerp to the correct z depth
	# We don't want to lerp to the correct z depth *and* lerp to the edge of the area because then it would move too fast
	var unprojected_position = main_camera.unproject_position(global_position)
	var weight: float = 1 - exp(-lerp_speed * delta) # Makes it framerate-independent like it says in:
	# https://docs.godotengine.org/en/stable/tutorials/math/interpolation.html#smoothing-motion
	
	# Skip if behind the camera like it says to do in the Camera3D project_position docs
	if main_camera.is_position_behind(global_position):
		_move_to_correct_z_depth(unprojected_position, weight)
		return Vector3.ZERO
	
	# Skip if it's inside the area it shouldn't be moving in
	if counterpart_in_2d_rect.has_point(unprojected_position):
		_move_to_correct_z_depth(unprojected_position, weight)
		return Vector3.ZERO
	
	# Update the collsion/collider shape in case the 2d counterpart control node has resized
	# You don't need to check for positional movements because the collision_area should be a child of the 2d counterpart
	var collision_shape: CollisionShape2D = collision_area.get_child(0)
	collision_shape.position = counterpart_in_2d_rect.size / 2
	var collider_shape: RectangleShape2D = collision_shape.shape
	collider_shape.size = counterpart_in_2d_rect.size
	
	# Move the menu scene's 2d raycast (not create a new one because that's unnecessarily costly)
	var raycast: RayCast2D = Nodes.menu.ray_cast_2d
	raycast.global_position = unprojected_position
	raycast.target_position = collision_shape.global_position - unprojected_position
	raycast.collision_mask = collision_area.collision_layer
	raycast.force_raycast_update()
	
	# None of what's about to follow will work if the raycast isn't colliding. It should be, but good to check
	if not raycast.is_colliding():
		_move_to_correct_z_depth(unprojected_position, weight)
		return Vector3.ZERO
	
	# Get the colliding point in 2D space and project it into 3D space from the main camera
	var colliding_point := raycast.get_collision_point()
	var edge_of_area := main_camera.project_position(colliding_point, z_depth)
	
	# Lerp to the edge of the area
	global_position = global_position.lerp(edge_of_area, weight)
	# Return true because it's outside the area
	return edge_of_area


func _move_to_correct_z_depth(unprojected_position: Vector2, weight: float) -> void:
	var projected_position = get_viewport().get_camera_3d().project_position(unprojected_position, z_depth)
	global_position = global_position.lerp(projected_position, weight)


func _handle_rotation(delta: float, edge_of_area: Vector3) -> void:
	if not turn_to_camera:# or (not is_outside_area and follow_mouse):
		return
	
	if follow_mouse:
		if not edge_of_area:
			return
		
		# Get the basis it needs to slerp to
		var viewport := get_viewport()
		var main_camera := viewport.get_camera_3d()
		var new_basis := Basis.looking_at(edge_of_area - main_camera.global_position)
		# Turn the y basis to face upwards in accordance with the main camera's center and not where this node is
		# You can comment out these three lines and see what happens when you look up and down if you're curious
		var looking_at_position := main_camera.project_position(viewport.get_visible_rect().size / 2, z_depth)
		var main_camera_basis := Basis.looking_at(looking_at_position - main_camera.global_position)
		
		Debug.modify_3d_line(debug_line_1, [looking_at_position, new_basis.x + looking_at_position], Color.RED)
		Debug.modify_3d_line(debug_line_2, [looking_at_position, new_basis.y + looking_at_position], Color.GREEN)
		Debug.modify_3d_line(debug_line_3, [looking_at_position, new_basis.z + looking_at_position], Color.BLUE)
		Debug.modify_3d_line(debug_line_4, [looking_at_position, main_camera_basis.x + looking_at_position], Color.CYAN)
		Debug.modify_3d_line(debug_line_5, [looking_at_position, main_camera_basis.y + looking_at_position], Color.YELLOW)
		Debug.modify_3d_line(debug_line_6, [looking_at_position, main_camera_basis.z + looking_at_position], Color.MAGENTA)
		
		Debug.debug_print(name, new_basis.y.signed_angle_to(main_camera_basis.y, new_basis.z))
		Debug.debug_print(name + "i", new_basis.y.signed_angle_to(main_camera_basis.y, new_basis.x))
		
		new_basis = new_basis.rotated(main_camera_basis.z, new_basis.y.signed_angle_to(main_camera_basis.y, main_camera_basis.z))
		
		Debug.modify_3d_line(debug_line_7, [looking_at_position, new_basis.x + looking_at_position], Color.TEAL)
		Debug.modify_3d_line(debug_line_8, [looking_at_position, new_basis.y + looking_at_position], Color.ORANGE)
		Debug.modify_3d_line(debug_line_9, [looking_at_position, new_basis.z + looking_at_position], Color.PURPLE)
		
		# Get the weight for slerping it (love that word lmao)
		var weight: float = 1 - exp(-turn_slerp_speed * delta) # Makes it framerate-independent like it says in:
		# https://docs.godotengine.org/en/stable/tutorials/math/interpolation.html#smoothing-motion
		global_basis = global_basis.slerp(new_basis, weight)
		
	else:
		# Get the basis it needs to slerp to
		var viewport := get_viewport()
		var main_camera := viewport.get_camera_3d()
		var new_basis := Basis.looking_at(global_position - main_camera.global_position)
		# Turn the y basis to face upwards in accordance with the main camera's center and not where this node is
		# You can comment out these three lines and see what happens when you look up and down if you're curious
		var looking_at_position := main_camera.project_position(viewport.get_visible_rect().size / 2, z_depth)
		var main_camera_basis := Basis.looking_at(looking_at_position - main_camera.global_position)
		
		new_basis = new_basis.rotated(new_basis.z, new_basis.y.signed_angle_to(main_camera_basis.y, new_basis.z))
		
		# Get the weight for slerping it (love that word lmao)
		var weight: float = 1 - exp(-turn_slerp_speed * delta) # Makes it framerate-independent like it says in:
		# https://docs.godotengine.org/en/stable/tutorials/math/interpolation.html#smoothing-motion
		global_basis = global_basis.slerp(new_basis, weight)
