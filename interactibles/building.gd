class_name BuildingNode
extends StaticBody3D


const NEAREST_POINTS_COUNT = 2
const MAX_CONNECTING_DISTANCE = 7
const MAX_SELECTING_DISTANCE = 1

const VERTEX_POINT = preload("res://vfx/vertex_point.tscn")

var points: PackedVector3Array = [
	Vector3(1, 0, 1),
	Vector3(-1, 0, 1),
	Vector3(1, 0, -1),
	Vector3(-1, 0.3, -1),
]
var colors: PackedColorArray = [
	Color.from_ok_hsl(0.0, 1.0, 0.8),
	Color.from_ok_hsl(0.25, 1.0, 0.8),
	Color.from_ok_hsl(0.5, 1.0, 0.8),
	Color.from_ok_hsl(0.75, 1.0, 0.8),
]

var coloring: int = -1

@onready var mesh: MeshInstance3D = $Mesh
@onready var collider: CollisionShape3D = $Collider
@onready var selector_mesh: MeshInstance3D = $SelectorMesh
@onready var vertex_points: Node3D = $VertexPoints
@onready var debug_label: Label = $CanvasLayer/DebugLabel


func _enter_tree() -> void:
	Nodes.building = self


func _ready() -> void:
	_process_points.call_deferred(true)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and coloring >= 0:
		var col: Color = colors[coloring]
		colors[coloring] = Color.from_ok_hsl(col.ok_hsl_h + event.relative.x / 1000.0, col.ok_hsl_s, col.ok_hsl_l + event.relative.y / 1000.0)
		get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	var has_processed_points := false
	
	# Add new points
	if Input.is_action_just_pressed("build") and PlayerState.is_playing_game:
		points.append(Nodes.player.point_manipulator.global_position)
		colors.append(Color.from_ok_hsl(randf(), 1.0, 0.8))
		
		_process_points(true)
		has_processed_points = true
	
	# Move points
	if Input.is_action_pressed("select") and Building.closest_point_to_manipulator >= 0 and PlayerState.is_playing_game:
		points[Building.closest_point_to_manipulator] = Nodes.player.point_manipulator.global_position
		if Input.is_action_pressed("color"):
			Nodes.player.mouse_captured = false
			coloring = Building.closest_point_to_manipulator
		
		if not has_processed_points:
			_process_points(true)
			has_processed_points = true
	
	if Input.is_action_just_released("color"):
		Nodes.player.mouse_captured = true
		coloring = -1
	
	if not has_processed_points:
		_process_points(false)
	
	# Move the selector to the manipulated point
	_move_selector_mesh(Building.closest_point_to_manipulator)
	
	debug_label.text = str(points.size()) + "\n" + str(Engine.get_frames_per_second())


func _move_selector_mesh(closest_point_to_manipulator: int) -> void:
	if closest_point_to_manipulator < 0:
		selector_mesh.global_position = Nodes.player.point_manipulator.global_position
	else:
		selector_mesh.global_position = points[closest_point_to_manipulator]


func _process_points(calculate_points: bool) -> void:
	# Setup pre-process things
	Building.points = points
	Building.colors = colors
	Building.manipulator_global_position = Nodes.player.point_manipulator.global_position
	
	# Process the points
	_profile_process_points(calculate_points)
	
	if calculate_points:
		# Generate the mesh and collider
		_profile_generate_mesh()
		_profile_generate_collision()
		
		# Add points for vertices
		_add_verticy_points()


func _profile_process_points(calculate_points: bool) -> void:
	Building.process_points(calculate_points)


func _profile_generate_mesh() -> void:
	mesh.mesh = Building.generate_mesh()


func _profile_generate_collision() -> void:
	var shape: ConcavePolygonShape3D = collider.shape as ConcavePolygonShape3D
	shape.set_faces(Building.vertices)


func _add_verticy_points() -> void:
	for child in vertex_points.get_children():
		child.queue_free()
	for point in points:
		var new_vertex_point = VERTEX_POINT.instantiate()
		vertex_points.add_child(new_vertex_point)
		new_vertex_point.global_position = point
