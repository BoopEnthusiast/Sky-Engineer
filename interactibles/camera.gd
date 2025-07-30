class_name PlayerCamera
extends Camera3D


@onready var player: Player = $".."


func _process(_delta: float) -> void:
	if is_instance_valid(player.inventory_selector.selected_inventory_slot):
		pass # do something
	
	var closest_found_thing: Player.Grabbable = Player.Grabbable.NOTHING
	var closest_found_thing_distance: float = INF
	
	if (
			Nodes.world.buildings.size() >= 0 
			and Building.closest_building_to_manipulator >= 0
			and Building.closest_point_to_manipulator >= 0
	):
		var position_of_vertex: Vector3 = Nodes.world.buildings[Building.closest_building_to_manipulator].points[Building.closest_point_to_manipulator]
		closest_found_thing = Player.Grabbable.VERTEX
		closest_found_thing_distance = position_of_vertex.distance_squared_to(player.point_manipulator.global_position)
		Nodes.world.selector_mesh.global_position = position_of_vertex
	
	if is_instance_valid(player.item_selector.selected_item):
		var distance_to_item = player.item_selector.selected_item.global_position.distance_squared_to(player.point_manipulator.global_position)
		if distance_to_item < closest_found_thing_distance:
			closest_found_thing = Player.Grabbable.ITEM
			closest_found_thing_distance = distance_to_item
			Nodes.world.selector_mesh.global_position = player.item_selector.selected_item.global_position
	
	if closest_found_thing == Player.Grabbable.NOTHING:
		Nodes.world.selector_mesh.global_position = player.point_manipulator.global_position
	
	if Input.is_action_pressed(&"select"):
		if is_instance_valid(player.currently_grabbing):
			if player.currently_grabbing is BuildingNode:
				Nodes.world.buildings[Building.closest_building_to_manipulator].points[Building.closest_point_to_manipulator] = player.point_manipulator.global_position
			else:
				player.currently_grabbing.global_position = player.point_manipulator.global_position
		elif closest_found_thing  == Player.Grabbable.VERTEX:
			Nodes.world.buildings[Building.closest_building_to_manipulator].points[Building.closest_point_to_manipulator] = player.point_manipulator.global_position
			player.currently_grabbing = Nodes.world.buildings[Building.closest_building_to_manipulator]
		elif closest_found_thing == Player.Grabbable.ITEM:
			player.item_selector.selected_item.global_position = player.point_manipulator.global_position
			player.currently_grabbing = player.item_selector.selected_item
		else:
			player.currently_grabbing = null
	else:
		player.currently_grabbing = null
