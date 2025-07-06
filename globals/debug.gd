extends Node


var debug_label: Label
var label_variables: Dictionary[StringName, String]


func _ready() -> void:
	debug_label = Label.new()
	add_child(debug_label)


## Taken from https://youtu.be/JnrhURF1jgM
func create_line(pos_1: Vector3, pos_2: Vector3, color: Color = Color.WHITE) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := StandardMaterial3D.new()
	
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(pos_1)
	immediate_mesh.surface_add_vertex(pos_2)
	immediate_mesh.surface_end()
	
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	
	add_child(mesh_instance)
	
	return mesh_instance


## Takes a line mesh in (one from create_line) and changes its positions instead of creating a whole new mesh and stuff
func modify_line(line: MeshInstance3D, pos_1: Vector3, pos_2: Vector3, new_color: Color = Color.WHITE) -> void:
	var immediate_mesh: ImmediateMesh = line.mesh as ImmediateMesh
	var material := StandardMaterial3D.new()
	
	immediate_mesh.clear_surfaces()
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(pos_1)
	immediate_mesh.surface_add_vertex(pos_2)
	immediate_mesh.surface_end()
	
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = new_color


## Taken from https://youtu.be/JnrhURF1jgM
func create_point(pos: Vector3, radius = 0.05, color = Color.WHITE) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	var sphere_mesh := SphereMesh.new()
	var material := StandardMaterial3D.new()
	
	mesh_instance.mesh = sphere_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh_instance.position = pos
	
	sphere_mesh.radius = radius
	sphere_mesh.height = radius * 2
	sphere_mesh.material = material
	
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	material.no_depth_test = true
	
	add_child(mesh_instance)
	
	return mesh_instance


## Prints the value in the top left. This works similar to Unreal where the key means it won't print it on a second line
func debug_print(key: StringName, value: Variant) -> void:
	label_variables[key] = str(value)
	# Update the debug label each time it's written to
	debug_label.text = ""
	for each_key: String in label_variables:
		debug_label.text += label_variables[each_key] + '\n'


## Removes the debug print when you're done with it
func remove_debug_print(key: StringName) -> void:
	label_variables.erase(key)
