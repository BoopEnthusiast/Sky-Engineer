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
	if Input.is_action_just_pressed("build"):
		points.append(Nodes.player.point_manipulator.global_position)
	
	var vertices: PackedVector3Array
	
	var closest_point_to_manipulator: int = -1
	
	
	var i: int = 0
	for point: Vector3 in points:
		# Find the closest point to the point manipulator on the player
		var manipulator_position: Vector3 = Nodes.player.point_manipulator.global_position
		var distance_to_manipulator: float = point.distance_squared_to(manipulator_position)
		
		if distance_to_manipulator < MAX_SELECTING_DISTANCE and closest_point_to_manipulator < 0:
			closest_point_to_manipulator = i
		
		elif points[closest_point_to_manipulator].distance_squared_to(manipulator_position) > distance_to_manipulator \
		and distance_to_manipulator < MAX_SELECTING_DISTANCE:
			closest_point_to_manipulator = i
		
		# Find the two nearest points
		var nearest_points: Array[Vector3]
		for other_point: Vector3 in points:
			if other_point == point:
				continue
			
			var distance_between_points: float = point.distance_squared_to(other_point)
			
			if distance_between_points < MAX_CONNECTING_DISTANCE and nearest_points.size() < NEAREST_POINTS_COUNT:
				nearest_points.append(other_point)
			else:
				for near_point: Vector3 in nearest_points:
					if distance_between_points < MAX_CONNECTING_DISTANCE \
					and distance_between_points < point.distance_squared_to(near_point):
						nearest_points.erase(near_point)
						nearest_points.append(other_point)
						break
		
		# Create triangle from this point and the two closest ones
		if nearest_points.size() == NEAREST_POINTS_COUNT:
			vertices.append(point)
			for near_point: Vector3 in nearest_points:
				vertices.append(near_point)
		
		i += 1
	
	# Generate the mesh and collider
	_generate(vertices)
	
	if Input.is_action_pressed("select"):
		points[closest_point_to_manipulator] = Nodes.player.point_manipulator.global_position
	
	# Move the selector to the manipulated point
	_move_selector_mesh(closest_point_to_manipulator)


func _generate(vertices: PackedVector3Array) -> void:
	var surface = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for vertex: Vector3 in vertices:
		surface.add_vertex(vertex)
	
	mesh.mesh = surface.commit()
	
	var shape: ConcavePolygonShape3D = collider.shape as ConcavePolygonShape3D
	shape.set_faces(vertices)


func _move_selector_mesh(closest_point_to_manipulator: int) -> void:
	if closest_point_to_manipulator < 0:
		selector_mesh.global_position = Nodes.player.point_manipulator.global_position
	else:
		selector_mesh.global_position = points[closest_point_to_manipulator]
