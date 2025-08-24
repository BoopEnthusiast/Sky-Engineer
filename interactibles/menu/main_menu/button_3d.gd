class_name Button3D
extends ProjectedMenuItem


const LERP_SPEED = 4.0

var _is_mouse_inside: bool = false
var _initial_position: Vector2
var _last_mouse_position: Vector2


func _ready() -> void:
	super()
	if not counterpart_in_2d.is_node_ready():
		await counterpart_in_2d.ready
	_initial_position = counterpart_in_2d.position


func _process(delta: float) -> void:
	# Move towards mouse
	if _is_mouse_inside:
		var weight: float = 1 - exp(-LERP_SPEED * delta)
		#var position_to_move_to := _last_mouse_position - counterpart_in_2d.size / 2
		#position_to_move_to = position_to_move_to.direction_to(counterpart_in_2d.global_position) * lerp(position_to_move_to.length(), 0, 0.8)
		counterpart_in_2d.global_position = counterpart_in_2d.global_position.lerp(_last_mouse_position, weight)
	# Move back to start
	elif _initial_position != counterpart_in_2d.position:
		var weight: float = 1 - exp(-LERP_SPEED * delta)
		counterpart_in_2d.position = counterpart_in_2d.position.lerp(_initial_position, weight)
	# Get projected
	super(delta)


func _on_static_body_input_event(camera: Node, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseMotion:
		_last_mouse_position = get_viewport().get_camera_3d().unproject_position(event_position)


func _on_static_body_mouse_entered() -> void:
	_is_mouse_inside = true


func _on_static_body_mouse_exited() -> void:
	_is_mouse_inside = false
