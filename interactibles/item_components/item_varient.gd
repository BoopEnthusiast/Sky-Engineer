@tool
class_name ItemVarient
extends Node3D

@export var substance:Dictionary[StringName,Array] = Substances.STONE

#colour targets, these are the objects to which colour should be applied.
@export var primary_target:Resource

@export var secondary_target:Resource

@export var tertiary_target:Resource

func _ready():
	pass
	
func paint():
	if primary_target != null:
		primary_target.albedo_color = substance[&"colors"][0]
	
	if secondary_target != null:
		secondary_target.albedo_color = substance[&"colors"][1]
	
	if tertiary_target != null:
		tertiary_target.albedo_color = substance[&"colors"][2]
