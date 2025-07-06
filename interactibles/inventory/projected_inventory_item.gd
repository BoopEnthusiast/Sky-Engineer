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


var debug_line_1: MeshInstance3D
var debug_line_2: MeshInstance3D
var debug_line_3: MeshInstance3D
var debug_line_4: MeshInstance3D
var debug_line_5: MeshInstance3D
var debug_line_6: MeshInstance3D
var debug_line_7: MeshInstance3D
var debug_line_8: MeshInstance3D
var debug_line_9: MeshInstance3D


func _ready() -> void:
	debug_line_1 = Debug.create_line(Vector3.ZERO, Vector3.ZERO, Color.RED)
	debug_line_2 = Debug.create_line(Vector3.ZERO, Vector3.ZERO, Color.GREEN)
	debug_line_3 = Debug.create_line(Vector3.ZERO, Vector3.ZERO, Color.BLUE)
	debug_line_4 = Debug.create_line(Vector3.ZERO, Vector3.ZERO, Color.CYAN)
	debug_line_5 = Debug.create_line(Vector3.ZERO, Vector3.ZERO, Color.YELLOW)
	debug_line_6 = Debug.create_line(Vector3.ZERO, Vector3.ZERO, Color.MAGENTA)
	debug_line_7 = Debug.create_line(Vector3.ZERO, Vector3.ZERO, Color.TEAL)
	debug_line_8 = Debug.create_line(Vector3.ZERO, Vector3.ZERO, Color.ORANGE)
	debug_line_9 = Debug.create_line(Vector3.ZERO, Vector3.ZERO, Color.PURPLE)


func _process(delta: float) -> void:
	var position_to_move_to = reference_camera.project_position(counterpart_in_2d.global_position, z_depth)
	
	if not turn_to_camera:
		# Move to the screen position of the control node counterpoint
		position = position_to_move_to
		return
	
	# Move remote transform to the screen position of the control node counterpoint
	remote_transform.position = position_to_move_to
	
	var weight = 1 - exp(-lerp_speed * delta) # Makes it framerate-dependent like it says in:
	# https://docs.godotengine.org/en/stable/tutorials/math/interpolation.html#smoothing-motion
	var viewport = get_viewport()
	var main_camera = viewport.get_camera_3d()
	var new_basis = Basis.looking_at(global_position - main_camera.global_position)
	var looking_at_position = main_camera.project_position(viewport.get_visible_rect().size / 2, z_depth)
	var secondary_basis = Basis.looking_at(looking_at_position - main_camera.global_position)
	
	Debug.modify_line(debug_line_1, global_position, new_basis.x + global_position, Color.RED)
	Debug.modify_line(debug_line_2, global_position, new_basis.y + global_position, Color.GREEN)
	Debug.modify_line(debug_line_3, global_position, new_basis.z + global_position, Color.BLUE)
	Debug.modify_line(debug_line_4, looking_at_position, secondary_basis.x + looking_at_position, Color.CYAN)
	Debug.modify_line(debug_line_5, looking_at_position, secondary_basis.y + looking_at_position, Color.YELLOW)
	Debug.modify_line(debug_line_6, looking_at_position, secondary_basis.z + looking_at_position, Color.MAGENTA)
	
	#print((-main_camera.global_basis.z).dot(remote_transform.basis.z))
	#new_basis = new_basis.rotated(-global_basis.z, (-main_camera.global_basis.z).dot(remote_transform.basis.z))
	
	Debug.debug_print(&"new_basis", new_basis.y.signed_angle_to(secondary_basis.y, new_basis.z))
	
	new_basis = new_basis.rotated(new_basis.z, new_basis.y.signed_angle_to(secondary_basis.y, new_basis.z)).orthonormalized()
	
	Debug.modify_line(debug_line_7, global_position, new_basis.x + global_position, Color.TEAL)
	Debug.modify_line(debug_line_8, global_position, new_basis.y + global_position, Color.ORANGE)
	Debug.modify_line(debug_line_9, global_position, new_basis.z + global_position, Color.PURPLE)
	global_basis = global_basis.slerp(new_basis, weight / 2)
