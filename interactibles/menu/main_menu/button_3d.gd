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
	print("Node: " + counterpart_in_2d.name,"\t",_initial_position)


func _process(delta: float) -> void:
	# Move towards mouse
	if _is_mouse_inside:
		var weight: float = 1 - exp(-LERP_SPEED * delta)
		var position_to_move_to := _last_mouse_position - counterpart_in_2d.size / 2
		var distance_to_move := minf(position_to_move_to.length() * 0.1, position_to_move_to.distance_to(counterpart_in_2d.global_position))
		position_to_move_to = -position_to_move_to.direction_to(counterpart_in_2d.global_position) * distance_to_move  + _initial_position
		counterpart_in_2d.global_position = counterpart_in_2d.global_position.lerp(position_to_move_to, weight)
	# Move back to start
	elif _initial_position != counterpart_in_2d.position:
		var weight: float = 1 - exp(-LERP_SPEED * delta)
		counterpart_in_2d.position = counterpart_in_2d.position.lerp(_initial_position, weight)
	# Get projected
	super(delta)


func _on_static_body_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseMotion:
		_last_mouse_position = camera.unproject_position(event_position)


func _on_static_body_mouse_entered() -> void:
	_is_mouse_inside = true


func _on_static_body_mouse_exited() -> void:
	_is_mouse_inside = false
