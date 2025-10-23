class_name Mineral
extends Node3D

@export_category("Appearance")
@export var mineral_color: Color = Color(0.7, 0.7, 0.7, 1.0)
@export_range(0.0, 1.0) var mineral_opacity: float = 1.0
@export_range(0.1, 1.0) var mineral_size: float = 0.3

@export_category("Material")
@export_range(0.0, 1.0) var roughness: float = 0.5
@export_range(0.0, 1.0) var metallic: float = 0.0

@export_category("Variation")
@export var random_seed: int = 0
@export var randomize_on_spawn: bool = true
@export_range(6, 64) var segments: int = 16
@export_range(0.0, 0.2) var variation_strength: float = 0.05

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

@export var grabbable_item_scene: PackedScene

func _ready() -> void:
	if randomize_on_spawn and random_seed == 0:
		random_seed = randi()
	
	_regenerate_mesh()
	
	if not Engine.is_editor_hint():
		var world_ref := Nodes.world as World
		if world_ref:
			owner = world_ref
		
		# Add GrabbableItem at runtime to avoid editor issues
		if grabbable_item_scene:
			var grabbable = grabbable_item_scene.instantiate()
			add_child(grabbable)
			if "item_to_grab" in grabbable:
				grabbable.item_to_grab = self

# Generate mesh
func _regenerate_mesh() -> void:
	if not mesh_instance:
		return
	
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	
	var vertices = PackedVector3Array()
	var normals = PackedVector3Array()
	var uvs = PackedVector2Array()
	
	var rng = RandomNumberGenerator.new()
	rng.seed = random_seed
	
	var height_scale = 0.84
	var width_scale = 0.8
	
	var points: Array[Vector3] = []
	
	# Top and bottom
	points.append(Vector3(0, mineral_size * height_scale, 0))  # 0
	points.append(Vector3(0, -mineral_size * height_scale, 0)) # 1
	
	# Upper ring
	var upper_height = mineral_size * 0.5
	var upper_radius = mineral_size * 0.7 * width_scale
	for i in range(segments):
		var angle = (i / float(segments)) * TAU
		var x = cos(angle) * upper_radius
		var z = sin(angle) * upper_radius
		points.append(Vector3(x, upper_height, z))
	
	# Middle ring
	var middle_radius = mineral_size * width_scale
	for i in range(segments):
		var angle = (i / float(segments)) * TAU + (TAU / (segments * 2.0))
		var x = cos(angle) * middle_radius
		var z = sin(angle) * middle_radius
		points.append(Vector3(x, 0, z))
	
	# Lower ring
	var lower_height = -mineral_size * 0.5
	var lower_radius = mineral_size * 0.7 * width_scale
	for i in range(segments):
		var angle = (i / float(segments)) * TAU
		var x = cos(angle) * lower_radius
		var z = sin(angle) * lower_radius
		points.append(Vector3(x, lower_height, z))
	
	for i in range(points.size()):
		var strength := variation_strength
		
		if i < 2:  # tip 0 = top, 1 = bottom
			strength *= 3
			points[i] += Vector3(
				rng.randf_range(-strength, strength),   # X offset
				rng.randf_range(-0.1,+0.1),   # Y offset
				rng.randf_range(-strength, strength)    # Z offset
			) * mineral_size
		else:
			# Rings
			points[i] += Vector3(
				rng.randf_range(-strength, strength),
				rng.randf_range(-strength, strength) * 0.5,
				rng.randf_range(-strength, strength)
			) * mineral_size

	var centroid := Vector3.ZERO
	for p in points:
		centroid += p
	centroid /= points.size()
	for i in range(points.size()):
		points[i] -= centroid
	var faces: Array = []
	
	# Top cap
	for i in range(segments):
		var next_i = (i + 1) % segments
		faces.append([0, 2 + i, 2 + next_i])
	
	for i in range(segments):
		var next_i = (i + 1) % segments
		# Swap diagonal direction based on even/odd
		if i % 2 == 0:
			# Diagonal one way
			faces.append([2 + i, 2 + segments + i, 2 + next_i])
			faces.append([2 + next_i, 2 + segments + i, 2 + segments + next_i])
		else:
			# Diagonal other way
			faces.append([2 + i, 2 + segments + i, 2 + segments + next_i])
			faces.append([2 + i, 2 + segments + next_i, 2 + next_i])

	# Middle -> lower  
	for i in range(segments):
		var next_i = (i + 1) % segments
		if i % 2 == 0:
			faces.append([2 + segments + i, 2 + 2*segments + i, 2 + segments + next_i])
			faces.append([2 + segments + next_i, 2 + 2*segments + i, 2 + 2*segments + next_i])
		else:
			faces.append([2 + segments + i, 2 + 2*segments + i, 2 + 2*segments + next_i])
			faces.append([2 + segments + i, 2 + 2*segments + next_i, 2 + segments + next_i])
	
	# Bottom cap
	for i in range(segments):
		var next_i = (i + 1) % segments
		faces.append([1, 2 + 2*segments + next_i, 2 + 2*segments + i])
	
	# Add vertices
	for face in faces:
		var v1 = points[face[0]]
		var v2 = points[face[1]]
		var v3 = points[face[2]]
		var normal = (v2 - v1).cross(v3 - v1).normalized()
		
		vertices.append(v1)
		vertices.append(v2)
		vertices.append(v3)
		
		normals.append(normal)
		normals.append(normal)
		normals.append(normal)
		
		uvs.append(Vector2(0.5, 0))
		uvs.append(Vector2(0, 1))
		uvs.append(Vector2(1, 1))
	
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	
	var array_mesh = ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh_instance.mesh = array_mesh
	
	_update_material()

# Update material
func _update_material() -> void:
	if not mesh_instance:
		return
	
	var material = StandardMaterial3D.new()
	
	# Set base color
	material.albedo_color = Color(mineral_color.r, mineral_color.g, mineral_color.b, mineral_opacity)
	
	# Set transparency
	if mineral_opacity < 1.0:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.cull_mode = BaseMaterial3D.CULL_BACK  # Hide the inner faces
	else:
		material.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	
	# Set material
	material.roughness = roughness
	material.metallic = metallic
	
	mesh_instance.material_override = material
