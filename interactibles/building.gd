class_name BuildingNode
extends StaticBody3D


const NEAREST_POINTS_COUNT = 2
const MAX_CONNECTING_DISTANCE = 7
const MAX_SELECTING_DISTANCE = 1

const VERTEX_POINT = preload("res://vfx/vertex_point.tscn")
const DRAG_SPEED = 25.0

@export var building_index: int = 0

@export var points: PackedVector3Array = [
	Vector3(1, 0.03, 1),
	Vector3(-1, 0.01, 1),
	Vector3(1, 0.005, -1),
	Vector3(-1, 0.06, -1),
]
@export var colors: PackedColorArray = [
	Color.from_ok_hsl(0.0, 1.0, 0.8),
	Color.from_ok_hsl(0.25, 1.0, 0.8),
	Color.from_ok_hsl(0.5, 1.0, 0.8),
	Color.from_ok_hsl(0.75, 1.0, 0.8),
]

var had_selected_point: bool = false
var has_process_queued_up: bool = false

var _index_being_grabbed: int = -1
var _coloring: int = -1

@onready var mesh: MeshInstance3D = $Mesh
@onready var collider: CollisionShape3D = $Collider
@onready var selector_mesh: MeshInstance3D = $"../SelectorMesh"
@onready var vertex_points: Node3D = $VertexPoints


func _ready() -> void:
	mesh.mesh = mesh.mesh.duplicate()
	collider.shape = collider.shape.duplicate()
	_process_points.call_deferred(true)


func _unhandled_input(event: InputEvent) -> void:
	# Color the selected point
	if event is InputEventMouseMotion and _coloring >= 0:
		var col: Color = colors[_coloring]
		colors[_coloring] = Color.from_ok_hsl(col.ok_hsl_h + event.relative.x / 1000.0, 1.0, col.ok_hsl_l + event.relative.y / 1000.0)
		get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	var has_processed_points := false
	var is_current_building := Building.closest_building_to_manipulator == building_index
	
	if PlayerState.is_playing_game and is_current_building:
		var has_selected_point := Building.closest_point_to_manipulator >= 0
		
		# Add new points
		if Input.is_action_just_pressed(&"build") and Nodes.menu.counters.vertices_left > 0:
			Nodes.menu.counters.vertices_left -= 1
			if has_selected_point:
				points.append(Nodes.player.point_manipulator.global_position)
				colors.append(Color.from_ok_hsl(randf(), 1.0, 0.8))
				has_process_queued_up = true
			else:
				Nodes.world.create_new_building(Nodes.player.point_manipulator.global_position)
		
		# Destroy points
		if has_selected_point and Input.is_action_just_pressed(&"destroy"):
			Nodes.menu.counters.vertices_left += 1
			points.remove_at(Building.closest_point_to_manipulator)
			colors.remove_at(Building.closest_point_to_manipulator)
			if points.size() <= 0:
				Nodes.world.remove_building(self)
				queue_free()
			has_process_queued_up = true
		
		# Move points
		if _index_being_grabbed >= 0:
			if points[_index_being_grabbed] != Nodes.player.point_manipulator.global_position:
				var weight: float = 1 - exp(-DRAG_SPEED * delta)
				points[_index_being_grabbed] = points[_index_being_grabbed].lerp(Nodes.player.point_manipulator.global_position, weight)
				Nodes.world.selector_mesh.global_position = points[_index_being_grabbed]
				has_process_queued_up = true
			# Color point
			if Input.is_action_pressed(&"color"):
				# Color selected point (actual coloring logic is in _unhandled_input)
				Nodes.player.mouse_captured = false
				_coloring = _index_being_grabbed
				has_process_queued_up = true
	
	# Stop coloring points
	if Input.is_action_just_released(&"color"):
		Nodes.player.mouse_captured = true
		_coloring = -1
	
	if has_process_queued_up and not has_processed_points:
		has_process_queued_up = false
		_process_points(true)
		has_processed_points = true
	
	# Process the points (only to find the closest point to the manipulator) if not already processed points
	if not has_processed_points:
		_process_points(false)


func started_grabbing_this(vertex_index: int) -> void:
	_index_being_grabbed = vertex_index


func stopped_grabbing_this() -> void:
	_index_being_grabbed = -1
	_coloring = -1


func _process_points(calculate_points: bool) -> void:
	# Setup pre-process things
	Building.points = points
	Building.colors = colors
	Building.manipulator_global_position = Nodes.player.point_manipulator.global_position
	Building.building = building_index
	
	# Process the points
	Building.process_points(calculate_points)
	
	if calculate_points:
		# Generate the mesh and collider
		mesh.mesh = Building.generate_mesh()
		collider.shape.set_faces(Building.vertices)
		
		# Add points for vertices
		_add_verticy_points()


func _add_verticy_points() -> void:
	var vertex_points_child_count = vertex_points.get_child_count()
	var points_size = points.size()
	for i in range(max(vertex_points_child_count, points_size)):
		var vertex_point: MeshInstance3D
		if i >= vertex_points_child_count:
			vertex_point = VERTEX_POINT.instantiate()
			vertex_points.add_child(vertex_point)
		else:
			vertex_point = vertex_points.get_child(i)
			if i >= points_size:
				vertex_point.queue_free()
				continue
		
		vertex_point.global_position = points[i]
