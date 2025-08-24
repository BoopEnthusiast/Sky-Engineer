class_name ItemSelector
extends Area3D


const GRAB_SPEED = 4.0

var selectable_items: Array[ItemShape]
var selected_item: ItemShape
var selected_item_distance: float = INF


func _process(_delta: float) -> void:
	_update_selected_item()
	print(selectable_items,"\t\t",selected_item)


func _on_area_shape_entered(_area_rid: RID, area: Area3D, _area_shape_index: int, _local_shape_index: int) -> void:
	if area is not ItemShape:
		return
	selectable_items.append(area)
	_update_selected_item()


func _on_area_shape_exited(_area_rid: RID, area: Area3D, _area_shape_index: int, _local_shape_index: int) -> void:
	if area is not ItemShape:
		return
	selectable_items.erase(area)
	_update_selected_item()


func _update_selected_item() -> void:
	# If there's no items in range, select none of them
	if selectable_items.size() == 0:
		selected_item = null
		selected_item_distance = INF
		return
	
	# Update selected item distance
	if is_instance_valid(selected_item):
		selected_item_distance = global_position.distance_squared_to(selected_item.global_position)
	
	# Find the closest item to the item selector that's in range of the item selector
	var items_to_remove: Array[ItemShape]
	for selectable_item: ItemShape in selectable_items:
		if not is_instance_valid(selectable_item):
			items_to_remove.append(selectable_item)
			continue
		
		if not selectable_item.can_be_interacted_with or selectable_item == selected_item:
			continue
		
		if not is_instance_valid(selected_item):
			selected_item = selectable_item
		
		var distance_to_item: float = global_position.distance_squared_to(selectable_item.global_position)
		if distance_to_item < selected_item_distance:
			selected_item_distance = distance_to_item
			selected_item = selectable_item
	
	for item_to_remove: ItemShape in items_to_remove:
		selectable_items.erase(item_to_remove)
