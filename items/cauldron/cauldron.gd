class_name Cauldron
extends AnimatableBody3D

@onready var mesh:MeshInstance3D = $Mesh
@onready var varient:ItemVarient = $Varient
@onready var bubbles:GPUParticles3D = $Bubbles

const maxlevel:float = -1.72

const minlevel:float = -3.7

@export var substance:StringName

func _ready():
	varient.substance = Substances.SUBSTANCES[substance]
	varient.primary_target = mesh.material_override
	$BubbleVarient.substance = Substances.WOOD
	$BubbleVarient.secondary_target = bubbles.material_override
	varient.paint()
	$BubbleVarient.paint()
	_on_craft_area_started_crafting()
	

func set_level(level:float):
	bubbles.process_material.emission_shape_offset.y = lerp(minlevel,maxlevel,level/100)
	
	if level == 100 && bubbles.process_material.gravity.y != -3.01:
		bubbles.process_material.gravity.y = -3.01
	elif bubbles.process_material.gravity.y != -0.01:
		bubbles.process_material.gravity.y = -0.01


func _on_h_slider_value_changed(value: float) -> void:
	set_level(value)


func _on_craft_area_started_crafting() -> void:
	$AnimationPlayer.play("test")
