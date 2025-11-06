extends Area3D
## Handle node - manages all handle related functionality for the slider
signal value_changed(value: float)

@export var min_value: float = 0.0
@export var max_value: float = 100.0

var is_dragging: bool = false
var current_value: float = 50.0
var slider_half_length: float = 2.0
var base_slider_half_length: float = 2.0
var handle_mesh: MeshInstance3D
var _is_mouse_inside: bool = false

# Initialize handle 
func _ready():
	add_to_group("slider_handles")
	
	for child in get_children():
		if child is MeshInstance3D:
			handle_mesh = child
			break
	
	var slider_root = get_parent()
	var slider_bar = slider_root.get_node_or_null("StaticBody/Sliderbar")
	
	if slider_bar:
		var bar_scale = slider_bar.transform.basis.get_scale().x
		var mesh_size = 1.8
		var slider_scale = slider_root.transform.basis.get_scale().x
		base_slider_half_length = (bar_scale * slider_scale * mesh_size) / 2.0
		slider_half_length = base_slider_half_length
	else:
		base_slider_half_length = 2.0
		slider_half_length = 2.0
	
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	update_position()

func _on_mouse_entered():
	_is_mouse_inside = true

func _on_mouse_exited():
	_is_mouse_inside = false

# Handles mouse clicks to start/stop draggin
func _on_input_event(_camera, event, _click_position, _normal, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			get_viewport().set_input_as_handled()
			update_value_from_mouse()
		else:
			is_dragging = false

# Update slider position while dragging
func _process(_delta):
	if is_dragging:
		_update_slider_length()
		update_value_from_mouse()
		if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			is_dragging = false

# Makes sure that dragging stops if mouse button is released outside the slider
func _input(event: InputEvent):
	if is_dragging and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			is_dragging = false

# Update slider length based on parent scale
func _update_slider_length():
	var slider_root = get_parent()
	if slider_root:
		slider_half_length = base_slider_half_length * slider_root.scale.x

# Update handle pos based on mouse position
func update_value_from_mouse():
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return
	_update_slider_length()
	
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000
	
	var slider_root = get_parent()
	
	var slider_global_pos = slider_root.global_position
	var camera_forward = -camera.global_transform.basis.z
	var plane = Plane(camera_forward, slider_global_pos)
	
	var intersection = plane.intersects_ray(from, to)
	
	if intersection:
		var local_pos = slider_root.to_local(intersection)
		local_pos.x = clamp(local_pos.x, -slider_half_length, slider_half_length)
		var normalized = (local_pos.x + slider_half_length) / (slider_half_length * 2.0)
		set_value(lerp(min_value, max_value, normalized))

# Set a new slider value and emit signal if changed
func set_value(new_value: float):
	new_value = clamp(new_value, min_value, max_value)
	if abs(current_value - new_value) > 0.01:
		current_value = new_value
		update_position()
		value_changed.emit(current_value)

# Sets slider value without emitting signal
func set_value_no_signal(new_value: float):
	current_value = clamp(new_value, min_value, max_value)
	update_position()

# Update handle position based on current value
func update_position():
	var normalized = (current_value - min_value) / (max_value - min_value)
	var target_x = lerp(-slider_half_length, slider_half_length, normalized)
	
	position.x = target_x
	
	if handle_mesh:
		handle_mesh.position.x = 0

func get_value() -> float:
	return current_value
