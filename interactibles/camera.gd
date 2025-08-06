class_name PlayerCamera
extends Camera3D


@onready var player: Player = $".."
@onready var item_selector: ItemSelector = $PointManipulator/ItemSelector


func _process(delta: float) -> void:
	if is_instance_valid(player.inventory_selector.selected_inventory_slot):
		pass # TODO: do something
	
	# Setup variables for easy use
	var closest_building: BuildingNode = Nodes.world.buildings[Building.closest_building_to_manipulator]
	var closest_building_points: PackedVector3Array
	if Building.closest_building_to_manipulator >= 0:
		closest_building_points = closest_building.points
	
	var selected_item: ItemShape = item_selector.selected_item
	var selected_item_to_grab: Node3D
	if is_instance_valid(selected_item):
		selected_item_to_grab = selected_item.item_to_grab
	
	var currently_grabbing = player.currently_grabbing
	
	var closest_found_thing: Player.Grabbable = Player.Grabbable.NOTHING
	var closest_found_thing_distance: float = INF
	var is_already_grabbing: bool = is_instance_valid(currently_grabbing)
	
	# Only test for if something is closer to the player grabbing if the player isn't already grabbing
	if not is_already_grabbing:
		# Check if the building is the closest thing
		if (
				Nodes.world.buildings.size() >= 0 
				and Building.closest_building_to_manipulator >= 0
				and Building.closest_point_to_manipulator >= 0
		):
			var position_of_vertex: Vector3 = closest_building_points[Building.closest_point_to_manipulator]
			closest_found_thing = Player.Grabbable.VERTEX
			closest_found_thing_distance = position_of_vertex.distance_squared_to(player.point_manipulator.global_position)
			Nodes.world.selector_mesh.global_position = position_of_vertex
		
		# Check if the item selected is closer than the building
		if is_instance_valid(selected_item):
			var distance_to_item = selected_item_to_grab.global_position.distance_squared_to(player.point_manipulator.global_position)
			if distance_to_item < closest_found_thing_distance:
				closest_found_thing = Player.Grabbable.ITEM
				closest_found_thing_distance = distance_to_item
				Nodes.world.selector_mesh.global_position = selected_item_to_grab.global_position
	
	# If none are close enough, then move the selector mesh back to the point manipulator
	if closest_found_thing == Player.Grabbable.NOTHING:
		Nodes.world.selector_mesh.global_position = player.point_manipulator.global_position
	# If one is close enough, select and try to grab it
	elif Input.is_action_pressed(&"select"):
		# If already grabbing something, don't try to grab something else
		if is_already_grabbing:
			if currently_grabbing is BuildingNode:
				currently_grabbing.points[Building.closest_point_to_manipulator] = _move_point_to_point_manipulator(
						closest_building_points[Building.closest_point_to_manipulator],
						BuildingNode.DRAG_SPEED,
						delta
				)
				currently_grabbing.has_process_queued_up = true
			elif currently_grabbing is ItemShape:
				currently_grabbing.item_to_grab.global_position = _move_point_to_point_manipulator(
						currently_grabbing.item_to_grab.global_position,
						currently_grabbing.grab_weight,
						delta
				)
		# If not grabbing something and trying to grab a vertex, move the vertex and set you're already grabbing it
		elif closest_found_thing  == Player.Grabbable.VERTEX:
			closest_building_points[Building.closest_point_to_manipulator] = _move_point_to_point_manipulator(
					closest_building_points[Building.closest_point_to_manipulator],
					BuildingNode.DRAG_SPEED,
					delta
			)
			currently_grabbing = closest_building
			currently_grabbing.has_process_queued_up = true
		# If not grabbing something and trying to grab an item, move the item and set you're already grabbing it
		elif closest_found_thing == Player.Grabbable.ITEM:
			selected_item_to_grab.global_position = _move_point_to_point_manipulator(
					selected_item_to_grab.global_position, 
					selected_item.grab_weight, 
					delta
			)
			currently_grabbing = selected_item
		else:
			currently_grabbing = null
	else:
		currently_grabbing = null


func _move_point_to_point_manipulator(point: Vector3, move_speed: float, delta: float) -> Vector3:
	var weight: float = 1 - exp(-move_speed * delta)
	return point.lerp(player.point_manipulator.global_position, weight)
