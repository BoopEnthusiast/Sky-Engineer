@tool
class_name ItemVarient
extends Node3D

#colour values, these should probably be storded in their own global, along with similar features
var primary_tint:Color

var secondary_tint:Color

var tertiary_tint:Color

#colour targets, these are the objects to which colour should be applied.
@export var primary_target:Resource

@export var secondary_target:Resource

@export var tertiary_target:Resource

func _ready():
	pass
	
func paint():
	primary_target.albedo_color = primary_tint
	secondary_target.albedo_color = secondary_tint
	tertiary_target.albedo_color = tertiary_tint
