extends Marker3D


const MOVE_SPEED = 5.0

var position_to_move_to: Vector3 = position


func _process(delta: float) -> void:
	if Input.is_action_just_pressed(&"bring_closer"):
		position_to_move_to = position_to_move_to.move_toward(Vector3.FORWARD * 0.5, 0.5)
	elif Input.is_action_just_pressed(&"push_away"):
		position_to_move_to = position_to_move_to.move_toward(Vector3.FORWARD * 10.0, 0.5)
	
	var weight: float = 1.0 - exp(-MOVE_SPEED * delta)
	position = position.lerp(position_to_move_to, weight)
