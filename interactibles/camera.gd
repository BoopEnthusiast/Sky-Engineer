class_name PlayerCamera
extends Camera3D



var _closest_found_thing_type: Player.Grabbable = Player.Grabbable.NOTHING
var _closest_found_thing_distance: float = INF
var _previous_closest_item: ItemShape

@onready var _player: Player = $".."
@onready var _item_selector: ItemSelector = $PointManipulator/ItemSelector
@onready var _inventory_selector: InventorySelector = $InventorySelector


func _process(delta: float) -> void:
	_interact_with_inventory_slot()
	
	_find_closest_items()
	
	_move_grabbed_items(delta)


func _interact_with_inventory_slot() -> void:
	var selected_inventory_slot: InventorySlot = _inventory_selector.selected_inventory_slot
	
	if not is_instance_valid(selected_inventory_slot):
		return
	
	var is_currently_grabbing := is_instance_valid(_player.currently_grabbing)
	
	var currently_selected_has_item := is_instance_valid(selected_inventory_slot.currently_held_item)
	
	if Input.is_action_just_pressed("select") and not is_currently_grabbing and currently_selected_has_item:
		_player.currently_grabbing = selected_inventory_slot.currently_held_item
		selected_inventory_slot.currently_held_item.take_item_from_inventory(selected_inventory_slot)
	elif Input.is_action_just_released("select") and is_currently_grabbing:
		if _player.currently_grabbing is ItemShape and not currently_selected_has_item:
			_player.currently_grabbing.put_item_into_inventory(selected_inventory_slot)


func _find_closest_items() -> void:
	pass


func _move_grabbed_items(delta: float) -> void:
	# Setup variables for easy use
	var closest_building: BuildingNode = Nodes.world.buildings[Building.closest_building_to_manipulator]
	var closest_building_points: PackedVector3Array
	var is_closest_building_valid := Building.closest_building_to_manipulator >= 0
	if is_closest_building_valid:
		closest_building_points = closest_building.points
	
	var selected_item: ItemShape = _item_selector.selected_item
	var selected_item_to_grab: Node3D
	var is_selected_item_valid := is_instance_valid(selected_item)
	if is_selected_item_valid:
		selected_item_to_grab = selected_item.item_to_grab
	
	var selector_mesh: MeshInstance3D = Nodes.world.selector_mesh
	
	var closest_found_thing_type: Player.Grabbable = Player.Grabbable.NOTHING
	var closest_found_thing_distance: float = INF
	var is_already_grabbing := is_instance_valid(_player.currently_grabbing)
	
	# Only test for if something is closer to the player grabbing if the player isn't already grabbing
	if not is_already_grabbing:
		# Check if the building is the closest thing
		if (
				Nodes.world.buildings.size() >= 0 
				and is_closest_building_valid
				and Building.closest_point_to_manipulator >= 0
		):
			var position_of_vertex: Vector3 = closest_building_points[Building.closest_point_to_manipulator]
			closest_found_thing_type = Player.Grabbable.VERTEX
			closest_found_thing_distance = position_of_vertex.distance_squared_to(_player.point_manipulator.global_position)
			selector_mesh.global_position = position_of_vertex
		
		# Check if the item selected is closer than the building
		if is_selected_item_valid:
			var distance_to_item = selected_item_to_grab.global_position.distance_squared_to(_player.point_manipulator.global_position)
			if distance_to_item < closest_found_thing_distance:
				closest_found_thing_type = Player.Grabbable.ITEM
				closest_found_thing_distance = distance_to_item
				selector_mesh.global_position = selected_item_to_grab.global_position
	
	# If one is close enough, select and try to grab it
	if Input.is_action_pressed(&"select"):
		# If already grabbing something, don't try to grab something else
		if is_already_grabbing:
			if _player.currently_grabbing is BuildingNode:
				_player.currently_grabbing.points[Building.closest_point_to_manipulator] = _move_point_to_point_manipulator(
						closest_building_points[Building.closest_point_to_manipulator],
						BuildingNode.DRAG_SPEED,
						delta
				)
				_player.currently_grabbing.has_process_queued_up = true
			elif _player.currently_grabbing is ItemShape:
				_player.currently_grabbing.item_to_grab.global_position = _move_point_to_point_manipulator(
						_player.currently_grabbing.item_to_grab.global_position,
						_player.currently_grabbing.grab_weight,
						delta
				)
		# If not grabbing something and trying to grab a vertex, move the vertex and set you're already grabbing it
		elif closest_found_thing_type == Player.Grabbable.VERTEX:
			closest_building_points[Building.closest_point_to_manipulator] = _move_point_to_point_manipulator(
					closest_building_points[Building.closest_point_to_manipulator],
					BuildingNode.DRAG_SPEED,
					delta
			)
			_player.currently_grabbing = closest_building
			_player.currently_grabbing.has_process_queued_up = true
		# If not grabbing something and trying to grab an item, move the item and set you're already grabbing it
		elif closest_found_thing_type == Player.Grabbable.ITEM:
			selected_item_to_grab.global_position = _move_point_to_point_manipulator(
					selected_item_to_grab.global_position, 
					selected_item.grab_weight, 
					delta
			)
			_player.currently_grabbing = selected_item
			selected_item.no_longer_closest_item_to_selector()
			_previous_closest_item.no_longer_closest_item_to_selector()
			_previous_closest_item = selected_item
		else:
			_player.currently_grabbing = null
			if closest_found_thing_type == Player.Grabbable.NOTHING:
				_reset_selector_mesh_position()
	else:
		_player.currently_grabbing = null
		if closest_found_thing_type == Player.Grabbable.NOTHING:
			_reset_selector_mesh_position()
		
		if closest_found_thing_type != Player.Grabbable.ITEM:
			_previous_closest_item.no_longer_closest_item_to_selector()
		elif _previous_closest_item != selected_item:
			_update_closest_item(selected_item)


func _move_point_to_point_manipulator(point: Vector3, move_speed: float, delta: float) -> Vector3:
	var weight: float = 1 - exp(-move_speed * delta)
	var lerped_point := point.lerp(_player.point_manipulator.global_position, weight)
	Nodes.world.selector_mesh.global_position = lerped_point
	return lerped_point


func _reset_selector_mesh_position() -> void:
	Nodes.world.selector_mesh.global_position = _player.point_manipulator.global_position


func _update_closest_item(new_item: ItemShape) -> void:
	if new_item != _previous_closest_item and is_instance_valid(new_item):
		_previous_closest_item.no_longer_closest_item_to_selector()
		if new_item != _previous_closest_item and is_instance_valid(new_item):
			new_item.closest_item_to_selector()
			_previous_closest_item = new_item
