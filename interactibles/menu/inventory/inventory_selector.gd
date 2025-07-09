class_name InventorySelector
extends RayCast3D


func _process(_delta: float) -> void:
	var selector_ray = Nodes.player.inventory_selector
	selector_ray.force_raycast_update()
	
	if not selector_ray.is_colliding():
		Nodes.world.selected_inventory_slot = null
	elif selector_ray.get_collider() is InventorySlot:
		Nodes.world.selected_inventory_slot = selector_ray.get_collider()
	else:
		Nodes.world.selected_inventory_slot = null
