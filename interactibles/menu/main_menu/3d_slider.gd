@tool
extends ProjectedMenuItem
## Slider node - handles position syncing and hover expansion

signal hovered

var _is_mouse_inside := false

@onready var _mesh: MeshInstance3D = $StaticBody/Mesh
@onready var _static_body: StaticBody3D = $StaticBody
@onready var _text_mesh = get_node_or_null("StaticBody/TextMesh")

# Use a unique variable name for each instance
var _slider_text: String = ""

func _ready() -> void:
	_mesh.mesh = _mesh.mesh.duplicate(true)
	if _mesh.get_active_material(0):
		_mesh.set_surface_override_material(0, _mesh.get_active_material(0).duplicate())
	
	# Duplicate the text mesh for each instance
	if _text_mesh and _text_mesh.mesh:
		_text_mesh.mesh = _text_mesh.mesh.duplicate(true)
		_text_mesh.mesh.text = _slider_text
	
	if not Engine.is_editor_hint():
		if counterpart_in_2d and counterpart_in_2d is Control:
			super()

# Editor property with unique name
@export var slider_display_text: String = "":
	set(value):
		slider_display_text = value
		_slider_text = value
		if _text_mesh and _text_mesh.mesh is TextMesh:
			_text_mesh.mesh.text = value

# Syncs position and hover state with 2D counterpart
func _process(delta: float) -> void:
	if not Engine.is_editor_hint():
		if counterpart_in_2d and counterpart_in_2d is Control:
			super(delta)

# Triggered when the mous enters the slider
func _on_static_body_mouse_entered() -> void:
	_is_mouse_inside = true
	hovered.emit()
	if _mesh and _mesh.get_active_material(0):
		_mesh.get_active_material(0).albedo_color = Color.LIGHT_GRAY

	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3(0.7, 0.7, 0.7) * 1.1, 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

# Dont shrink immediately, wait a frame to check if we are over the handle
func _on_static_body_mouse_exited() -> void:
	call_deferred("_check_mouse_position")

# Checks whether the mouse truly left the slider after events are processed
func _check_mouse_position():
	if not _is_handle_hovered() and not _is_mouse_directly_over_slider():
		_is_mouse_inside = false
		if _mesh and _mesh.get_active_material(0):
			_mesh.get_active_material(0).albedo_color = Color.WHITE

		var tween = create_tween()
		tween.tween_property(self, "scale", Vector3(0.7, 0.7, 0.7), 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)


# Check if the handle is being hovered
func _is_handle_hovered() -> bool:
	var handle = get_node_or_null("HandleBody")
	if handle and handle is Area3D and handle.has_method("_is_mouse_inside"):
		return handle._is_mouse_inside
	return false


# Checks if the mouse cursor is still directly over the slider bar using raycasting
func _is_mouse_directly_over_slider() -> bool:
	var viewport = get_viewport()
	var mouse_pos = viewport.get_mouse_position()
	var camera = viewport.get_camera_3d()
	
	if not camera:
		return false
	
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	query.collision_mask = _static_body.collision_layer
	
	var result = space_state.intersect_ray(query)
	
	if result:
		return result.collider == _static_body
	
	return false
