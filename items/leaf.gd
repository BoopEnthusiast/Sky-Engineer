@tool
class_name Leaf
extends Node

# params without leafgen
@export var leaf_color: Color = Color(0.35, 0.7, 0.25)
@export var leaf_length: float = 0.4
@export var leaf_width: float = 0.15
@export var noise_seed: int = 0

# Ref
var mesh_instance: MeshInstance3D

func _ready() -> void:
	# Add to leaves group
	if not Engine.is_editor_hint():
		add_to_group("leaves")
	
	# new mesh :P 
	mesh_instance = MeshInstance3D.new()
	mesh_instance.name = "Mesh"
	add_child(mesh_instance)
	
	generate_leaf_mesh()
	apply_material()
	
	if not Engine.is_editor_hint():
		await get_tree().process_frame
		
		# Set up grabber
		var grabbable = get_node_or_null("GrabbableItem")
		if grabbable:
			if "item_to_grab" in grabbable:
				grabbable.item_to_grab = self
				grabbable.grab_weight = 15.0  # Selected leaf gets nice boosted speed cause magnetics already have lag, dont want double
			if "can_be_interacted_with" in grabbable:
				grabbable.can_be_interacted_with = true
			
			if grabbable.has_signal("grabbed_by_player"):
				grabbable.grabbed_by_player.connect(on_grabbed)
			if grabbable.has_signal("no_longer_grabbed_by_player"):
				grabbable.no_longer_grabbed_by_player.connect(on_released)
		else:
			print("grab fix")
	

func generate_leaf_mesh() -> void:
	if not mesh_instance:
		mesh_instance = get_node_or_null("Mesh")
		if not mesh_instance:
			mesh_instance = MeshInstance3D.new()
			mesh_instance.name = "Mesh"
			add_child(mesh_instance)
	
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# Noise seed(leaf variation)
	var rng = RandomNumberGenerator.new()
	rng.seed = noise_seed
	
	# Low poly segments/slices
	var segments = 4
	
	# Create vertices with noise except at base and tip cause it can cross points
	var vertices: Array[Vector3] = []
	var noise_strength = 0.0002
	
	for i in range(segments + 1):
		var t = float(i) / float(segments)
		var z = -leaf_length/2 + leaf_length * t
		
		# Width changes along the leaf(diamond shape)
		var width_factor: float
		if t < 0.4:
			width_factor = t / 0.4  # Widen
		elif t < 0.7:
			width_factor = 1.0  # Max width
		else:
			width_factor = (1.0 - t) / 0.3  # Decrease too tip
		
		var current_width = leaf_width * width_factor
		
		# Add noise to middle vertices only not base/tip
		var noise_x = 0.0
		var noise_y = 0.0
		if i > 0 and i < segments:
			noise_x = rng.randf_range(-noise_strength, noise_strength)
			noise_y = rng.randf_range(-noise_strength/2, noise_strength)
		
		# Left and right vertices
		var left_vert = Vector3(-current_width + noise_x, noise_y, z)
		var right_vert = Vector3(current_width + noise_x, noise_y, z)
		
		vertices.append(left_vert)
		vertices.append(right_vert)
	
	# Spine vertices(Work in progress)
	var spine_vertices: Array[Vector3] = []
	for i in range(segments + 1):
		var t = float(i) / float(segments)
		var z = -leaf_length/2 + leaf_length * t
		
		# Slight height increase for the spine 
		var spine_height = 0.01
		spine_vertices.append(Vector3(0, spine_height, z))
	
	# Build triangles with surface tool
	for i in range(segments):
		# Left side triangles from spine
		# Triangle 1. spine_bottom - left_bottom - spine_top
		surface_tool.set_normal(Vector3.UP)
		surface_tool.set_uv(Vector2(0.5, float(i) / segments))
		surface_tool.add_vertex(spine_vertices[i])
		
		surface_tool.set_normal(Vector3.UP)
		surface_tool.set_uv(Vector2(0, float(i) / segments))
		surface_tool.add_vertex(vertices[i * 2])
		
		surface_tool.set_normal(Vector3.UP)
		surface_tool.set_uv(Vector2(0.5, float(i + 1) / segments))
		surface_tool.add_vertex(spine_vertices[i + 1])
		
		# Triangle 2, left_bottom - left_top - spine_top
		surface_tool.set_normal(Vector3.UP)
		surface_tool.set_uv(Vector2(0, float(i) / segments))
		surface_tool.add_vertex(vertices[i * 2])
		
		surface_tool.set_normal(Vector3.UP)
		surface_tool.set_uv(Vector2(0, float(i + 1) / segments))
		surface_tool.add_vertex(vertices[(i + 1) * 2])
		
		surface_tool.set_normal(Vector3.UP)
		surface_tool.set_uv(Vector2(0.5, float(i + 1) / segments))
		surface_tool.add_vertex(spine_vertices[i + 1])
		
		# Right side triangles from spine
		# Triangle 3, spine_bottom - spine_top - right_bottom
		surface_tool.set_normal(Vector3.UP)
		surface_tool.set_uv(Vector2(0.5, float(i) / segments))
		surface_tool.add_vertex(spine_vertices[i])
		
		surface_tool.set_normal(Vector3.UP)
		surface_tool.set_uv(Vector2(0.5, float(i + 1) / segments))
		surface_tool.add_vertex(spine_vertices[i + 1])
		
		surface_tool.set_normal(Vector3.UP)
		surface_tool.set_uv(Vector2(1, float(i) / segments))
		surface_tool.add_vertex(vertices[i * 2 + 1])
		
		# Triangle 4, spine_top - right_top - right_bottom
		surface_tool.set_normal(Vector3.UP)
		surface_tool.set_uv(Vector2(0.5, float(i + 1) / segments))
		surface_tool.add_vertex(spine_vertices[i + 1])
		
		surface_tool.set_normal(Vector3.UP)
		surface_tool.set_uv(Vector2(1, float(i + 1) / segments))
		surface_tool.add_vertex(vertices[(i + 1) * 2 + 1])
		
		surface_tool.set_normal(Vector3.UP)
		surface_tool.set_uv(Vector2(1, float(i) / segments))
		surface_tool.add_vertex(vertices[i * 2 + 1])
	
	# Generate normals for lighting
	surface_tool.generate_normals()
	mesh_instance.mesh = surface_tool.commit()

func apply_material() -> void:
	var material = StandardMaterial3D.new()
	material.albedo_color = leaf_color
	material.roughness = 0.8
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh_instance.material_override = material


func on_grabbed() -> void:
	# Dont want it getting pulled by others if its the pull
	if is_in_group("Magnetic"):
		remove_from_group("Magnetic")

	# Disable grabbing on grab
	get_tree().call_group("leaves", "disable_grabbing")
	
	# undoing it for this leaf since it's the one being grabbed
	var grabbable = get_node_or_null("GrabbableItem")
	if grabbable and "can_be_interacted_with" in grabbable:
		grabbable.can_be_interacted_with = true
	
	# Increasing pull force for selected leaf
	var magnetic = get_node_or_null("MagneticShape")
	if magnetic and "pull_force" in magnetic:
		magnetic.pull_force = 10.0
	

func on_released() -> void:
	# Add back to Magnetic group so it can be pulled again
	if not is_in_group("Magnetic"):
		add_to_group("Magnetic")
	
	# Leaves can be grabbed again
	get_tree().call_group("leaves", "enable_grabbing")
	
	# Reset pull force for leaf
	var magnetic = get_node_or_null("MagneticShape")
	if magnetic and "pull_force" in magnetic:
		magnetic.pull_force = 5.0
	

# Helper functions so dont get repeated code
func disable_grabbing() -> void:
	var grabbable = get_node_or_null("GrabbableItem")
	if grabbable and "can_be_interacted_with" in grabbable:
		grabbable.can_be_interacted_with = false

func enable_grabbing() -> void:
	var grabbable = get_node_or_null("GrabbableItem")
	if grabbable and "can_be_interacted_with" in grabbable:
		grabbable.can_be_interacted_with = true
