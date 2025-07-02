extends Node3D


@export_range(0.1, 3.0, 0.1, "or_greater") var camera_sens: float = 1

var mouse_captured: bool = false

var look_dir: Vector2


func _ready() -> void:
	capture_mouse()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		look_dir = event.relative * 0.001
		if mouse_captured: _rotate_camera()


func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true


func _rotate_camera(sens_mod: float = 1.0) -> void:
	rotation.y -= look_dir.x * camera_sens * sens_mod
	rotation.x = clamp(rotation.x - look_dir.y * camera_sens * sens_mod, -1.5, 1.5)
