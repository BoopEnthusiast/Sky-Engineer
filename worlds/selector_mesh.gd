class_name SelectorMesh
extends MeshInstance3D


var temp_color: Color:
	set(value):
		temp_color = value
		mesh.material.albedo_color = temp_color
