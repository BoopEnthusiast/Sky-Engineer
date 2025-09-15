class_name Cauldron
extends AnimatableBody3D

@onready var mesh:MeshInstance3D = $Mesh
@onready var varient:ItemVarient = $Varient
@onready var bubbles:GPUParticles3D = $Bubbles

const maxlevel:float = -1.72

const minlevel:float = -3.7

func _ready():
	varient.primary_target = mesh.material_override
	varient.secondary_target = bubbles.material_override
	varient.tertiary_target = bubbles.material_override
	varient.paint()
