extends MeshInstance3D

func _ready():
	var material = StandardMaterial3D.new()
	
	# Base color 
	material.albedo_color = Color(0.25, 0.12, 0.05)
	
	# Make it look flat/shiny like a stylized cartoon object
	material.roughness = 0.3
	material.metallic = 0.0
	
	# Add rim light effect for toon shading
	material.rim = 0.4
	material.rim_tint = 0.9
	
	# Slight emission to make the cover pop
	material.emission_enabled = true
	material.emission = Color(0.15, 0.25, 0.6) * 0.2  # faint glow
	
	# Assign to mesh
	self.material_override = material
