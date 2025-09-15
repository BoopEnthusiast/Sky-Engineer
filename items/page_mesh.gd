extends MeshInstance3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var pages_material = StandardMaterial3D.new()
	pages_material.albedo_color = Color(0.95, 0.9, 0.75)  # parchment / paper
	pages_material.roughness = 0.9
	pages_material.metallic = 0.0

	# Assign to mesh
	self.material_override = pages_material
