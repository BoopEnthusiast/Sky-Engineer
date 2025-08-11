class_name ItemSelector
extends Area3D


const GRAB_SPEED = 4.0

var selectable_items: Array[ItemShape]
var selected_item: ItemShape
var selected_item_distance: float = INF


func _on_area_shape_entered(_area_rid: RID, area: Area3D, _area_shape_index: int, _local_shape_index: int) -> void:
	if area is not ItemShape:
		return
	
	if not area.can_be_interacted_with:
		return
	
	selectable_items.append(area)
	
	# Find the closest item to the item selector that's in range of the item selector
	var closest_item: ItemShape = area
	var closest_distance: float = global_position.distance_squared_to(area.global_position)
	for selectable_item: ItemShape in selectable_items:
		if selectable_item == closest_item or not selectable_item.can_be_grabbed:
			continue
		
		var distance_to_item: float = global_position.distance_squared_to(selectable_item.global_position)
		if distance_to_item < closest_distance:
			closest_distance = distance_to_item
			closest_item = selectable_item
	
	# Set the selected item to that closest one
	selected_item = closest_item
	selected_item_distance = closest_distance


func _on_area_shape_exited(_area_rid: RID, area: Area3D, _area_shape_index: int, _local_shape_index: int) -> void:
	selectable_items.erase(area)
	if selectable_items.size() == 0:
		selected_item = null
		selected_item_distance = INF
