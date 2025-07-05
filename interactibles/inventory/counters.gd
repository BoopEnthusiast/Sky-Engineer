class_name Counters
extends ProjectedInventoryItem


@export var vertices_left: int = 5:
	set(value):
		vertices_left = value
		if is_instance_valid(vertices):
			vertices.mesh.text = str(value)

@onready var vertices: MeshInstance3D = $Vertices
