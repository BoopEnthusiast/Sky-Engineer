class_name Inventory
extends Node


@onready var inventory_3d: ProjectedMenuItem = $Inventory3D


func _process(_delta: float) -> void:
	var selector_ray = Nodes.player.inventory_selector
	selector_ray.force_raycast_update()
	
	if not selector_ray.is_colliding():
		return
	
	if not selector_ray.get_collider() is InventorySlot:
		return
	
	Nodes.world.selector_mesh.global_position = selector_ray.get_collision_point()
	Nodes.world.selector_mesh.temp_color = 
