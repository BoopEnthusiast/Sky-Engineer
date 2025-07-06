class_name Counters
extends ProjectedMenuItem


## The vertices the player has left to place. Changing this changes the mesh automatically.
@export var vertices_left: int = 5:
	set(value):
		vertices_left = value
		if is_instance_valid(_vertices):
			_vertices.mesh.text = str(value)

@onready var _vertices: MeshInstance3D = $Vertices
