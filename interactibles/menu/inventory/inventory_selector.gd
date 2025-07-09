class_name InventorySelector
extends RayCast3D


func _process(_delta: float) -> void:
	if not Nodes.menu.inventory.is_visible_in_tree():
		return
	
	force_raycast_update()
	
	if not is_colliding():
		Nodes.world.selected_inventory_slot = null
	elif get_collider() is InventorySlot:
		Nodes.world.selected_inventory_slot = get_collider()
	else:
		Nodes.world.selected_inventory_slot = null
