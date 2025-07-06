class_name Debug3DLine
extends MeshInstance3D
## A line to be made and handled by the Debug singleton.


## The mesh of this point. You can also use mesh instead of my_mesh, but it won't know it's a SphereMesh.
var my_mesh: ImmediateMesh
## The material of my_mesh. You can also use my_mesh.material instead of my_material, but it won't know it's a StandardMaterial3D.
var my_material: StandardMaterial3D


func _init() -> void:
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	my_mesh = ImmediateMesh.new()
	mesh = my_mesh
	
	my_material = StandardMaterial3D.new()
	my_mesh.material = my_material
	my_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	my_material.no_depth_test = true
