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

@onready var mesh: MeshInstance3D = $Mesh
@onready var collider: CollisionShape3D = $Collider
@onready var selector_mesh: MeshInstance3D = $SelectorMesh
@onready var vertex_points: Node3D = $VertexPoints


func _enter_tree() -> void:
	Nodes.building = self


func _process(_delta: float) -> void:
	# Add new points
	if Input.is_action_just_pressed("build"):
		points.append(Nodes.player.point_manipulator.global_position)
	
	_process_points()
	
	# Move points
	if Input.is_action_pressed("select") and Building.closest_point_to_manipulator >= 0:
		points[Building.closest_point_to_manipulator] = Nodes.player.point_manipulator.global_position
		
	# Move the selector to the manipulated point
	_move_selector_mesh(Building.closest_point_to_manipulator)


func _move_selector_mesh(closest_point_to_manipulator: int) -> void:
	if closest_point_to_manipulator < 0:
		selector_mesh.global_position = Nodes.player.point_manipulator.global_position
	else:
		selector_mesh.global_position = points[closest_point_to_manipulator]


func _process_points() -> void:
	# Setup pre-process things
	Building.points = points
	Building.manipulator_global_position = Nodes.player.point_manipulator.global_position
	
	# Process the points
	Building.process_points()
	
	# Generate the mesh and collider
	_profile_generate_mesh()
	_profile_generate_collision()
	
	# Add points for vertices
	_add_verticy_points()


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
