class_name BuildingNode
extends StaticBody3D


const NEAREST_POINTS_COUNT = 2
const MAX_CONNECTING_DISTANCE = 7
const MAX_SELECTING_DISTANCE = 1

var points: Array[Vector3] = [
	Vector3(1, 0, 1),
	Vector3(-1, 0, 1),
	Vector3(1, 0, -1),
	Vector3(-1, 1, -1),
]

@onready var mesh: MeshInstance3D = $Mesh
@onready var collider: CollisionShape3D = $Collider
@onready var selector_mesh: MeshInstance3D = $SelectorMesh


func _enter_tree() -> void:
	Nodes.building = self


func _process(_delta: float) -> void:
	print("0")
	if Input.is_action_just_pressed("build"):
		points.append(Nodes.player.point_manipulator.global_position)
	print("1")
	Building.points = points
	Building.manipulator_global_position = Nodes.player.point_manipulator.global_position
	print("2")
	Building.process_points()
	print("3")
	# Generate the mesh and collider
	Building.generate_mesh()
	var shape: ConcavePolygonShape3D = collider.shape as ConcavePolygonShape3D
	shape.set_faces(Building.vertices)
	print("4")
	if Input.is_action_pressed("select"):
		points[Building.closest_point_to_manipulator] = Nodes.player.point_manipulator.global_position
	print("5")
	# Move the selector to the manipulated point
	_move_selector_mesh(Building.closest_point_to_manipulator)


func _move_selector_mesh(closest_point_to_manipulator: int) -> void:
	if closest_point_to_manipulator < 0:
		selector_mesh.global_position = Nodes.player.point_manipulator.global_position
	else:
		selector_mesh.global_position = points[closest_point_to_manipulator]
