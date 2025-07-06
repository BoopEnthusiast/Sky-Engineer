class_name Inventory
extends Node3D


@onready var inventory_3d: ProjectedMenuItem = $Inventory3D
@onready var selection_decal: Decal = $SelectionDecal


func _process(_delta: float) -> void:
	var selector_ray = Nodes.player.inventory_selector
	selector_ray.force_raycast_update()
	
	if not selector_ray.is_colliding():
		return
	
	selection_decal.global_position = selector_ray.get_collision_point()
	selection_decal.look_at(selector_ray.get_collision_normal())
