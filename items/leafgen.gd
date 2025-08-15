@tool
class_name LeafGenerator
extends Node3D
## ADD THIS NODE TO WORLD SCENE, LEAF MANAGER
@export_file("*.tscn") var leaf_scene_path: String = "res://items/leaf.tscn"

@export_group("Spawn Settings")
@export var spawn_center: Vector3 = Vector3.ZERO
@export var spawn_radius: float = 0.8
@export var leaf_count: int = 10

@export_group("Leaf Variations")
@export_range(1.5, 3.0) var length_min: float = 1.75
@export_range(2.0, 3.0) var length_max: float = 3.0
@export_range(0.5, 1.0) var width_min: float = 0.6
@export_range(0.5, 1.0) var width_max: float = 0.9

# 3 colors to add more variation
const LEAF_COLORS = [
	Color(0.2, 0.4, 0.15),
	Color(0.35, 0.7, 0.25),
	Color(0.5, 0.6, 0.1),
]

# Save spawned leaves
var spawned_leaves: Array[Node3D] = []

## TESTING METHOD
#func _input(event: InputEvent) -> void:
#	if Engine.is_editor_hint():
#		return
#	
#	if event is InputEventKey and event.pressed:
#		# GENERATE ON " V "
#		if event.keycode == KEY_V:
#			clear_leaves()  # Clear for testing spawn pos
#			generate_leaves_at(spawn_center, spawn_radius, leaf_count)
#		# GENERAte ON " B "
#		if event.keycode == KEY_B:
#			var offset = Vector3(randf_range(-0.5, 0.5),0,randf_range(-0.5, 0.5))
#			generate_leaves_at(spawn_center + offset, spawn_radius, 30)


## TESTING METHOD
func clear_leaves() -> void:
	for leaf in spawned_leaves:
		if is_instance_valid(leaf):
			leaf.queue_free()
	spawned_leaves.clear()


func generate_leaves_at(center: Vector3, radius: float, count: int) -> void:
	var leaf_scene = load(leaf_scene_path)
	if not leaf_scene:
		push_error("Leaf Scene not found, " + leaf_scene_path)
		return
	
	for i in range(count):
		var leaf_instance = spawn_single_leaf(leaf_scene, center, radius, i)
		if leaf_instance:
			add_child(leaf_instance)
			spawned_leaves.append(leaf_instance)


func spawn_single_leaf(leaf_scene: PackedScene, center: Vector3, radius: float, index: int) -> Node3D:
	var leaf_instance = leaf_scene.instantiate()
	# I made positioning before magnet, may be useful later depending on what happens with magnet: P
	
	# Random position around center
	var angle = randf() * 2
	var distance = randf() * radius
	var height_offset = randf_range(0, 0.3)
	leaf_instance.position = center + Vector3(
		cos(angle) * distance,# X offset
		height_offset,
		sin(angle) * distance # Z offset
	)
	
	# Rotation
	leaf_instance.rotation = Vector3(
		randf_range(-PI/4, PI/4), #  capping roll at 45 degree, doesnt matter rn but if leaf model is updated it may
		randf() * PI * 2, # spin/pan leaves can point any direction on x
		0 # Leaves facing sun, dont roll
	)
	
	# Leaf Scale
	var scale_factor = randf_range(1,2)
	leaf_instance.scale = Vector3.ONE * scale_factor
	
	# Random mods to leaf color and vertices
	if leaf_instance.has_method("generate_leaf_mesh"):
		leaf_instance.leaf_color = LEAF_COLORS[randi() % LEAF_COLORS.size()]
		leaf_instance.leaf_length = randf_range(length_min, length_max)
		leaf_instance.leaf_width = randf_range(width_min, width_max)
		leaf_instance.noise_seed = index + randi()
		
		# Regen mesh with changes
		leaf_instance.generate_leaf_mesh()
		leaf_instance.apply_material()
	
	if Engine.is_editor_hint():
		leaf_instance.owner = get_tree().edited_scene_root
	
	return leaf_instance

# Create singular leaf at pos
func create_leaf_at_position(pos: Vector3) -> Node3D:
	var leaf_scene = load(leaf_scene_path)
	if not leaf_scene:
		push_error("Leaf Scene not found, " + leaf_scene_path)
		return null
	
	var leaf = spawn_single_leaf(leaf_scene, pos, 0, spawned_leaves.size())
	if leaf:
		add_child(leaf)
		spawned_leaves.append(leaf)
	return leaf


func delete_self():
	queue_free()
