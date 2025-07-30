class_name InventorySelector
extends RayCast3D


var selected_inventory_slot: InventorySlot


func _process(_delta: float) -> void:
	if not Nodes.menu.inventory.is_visible_in_tree():
		return
	
	force_raycast_update()
	
	if not is_colliding():
		selected_inventory_slot = null
	elif get_collider() is InventorySlot:
		selected_inventory_slot = get_collider()
	else:
		selected_inventory_slot = null
