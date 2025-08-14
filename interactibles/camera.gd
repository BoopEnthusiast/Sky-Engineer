class_name PlayerCamera
extends Camera3D


# I'd like to use a closure to have these variables only accessible to _find_closest_items and _move_grabbed_items, but that's not really possible (actually it kinda is with local classes/returning callables) so I'm just making them private global variables in the script
var _closest_building: BuildingNode
var _closest_building_points: PackedVector3Array
var _is_closest_building_valid: bool

var _selected_item: ItemShape
var _selected_item_to_grab: Node3D
var _is_selected_item_valid: bool
var _is_selected_item_grabbable: bool

var _selector_mesh: MeshInstance3D = Nodes.world.selector_mesh

var _closest_found_thing_type: Player.Grabbable
var _closest_found_thing_distance: float
var _is_already_grabbing: bool

var _previous_closest_item: ItemShape

@onready var _player: Player = $".."
@onready var _item_selector: ItemSelector = $PointManipulator/ItemSelector
@onready var _inventory_selector: InventorySelector = $InventorySelector


func _process(_delta: float) -> void:
	_interact_with_inventory_slot()
	
	_update_global_variables()
	
	_find_closest_items()
	
	_move_grabbed_items()


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


func _update_global_variables() -> void:
	_closest_found_thing_type = Player.Grabbable.NOTHING
	_closest_found_thing_distance = INF
	_closest_building = Nodes.world.buildings[Building.closest_building_to_manipulator]
	_is_closest_building_valid = Building.closest_building_to_manipulator >= 0
	if _is_closest_building_valid:
		_closest_building_points = _closest_building.points
	
	_selected_item = _item_selector.selected_item
	_is_selected_item_valid = is_instance_valid(_selected_item)
	_is_selected_item_grabbable = _selected_item is GrabbableItem
	if _is_selected_item_valid and _is_selected_item_grabbable:
		_selected_item_to_grab = _selected_item.item_to_grab
	
	_selector_mesh = Nodes.world.selector_mesh
	
	_closest_found_thing_type = Player.Grabbable.NOTHING
	_closest_found_thing_distance = INF
	_is_already_grabbing = is_instance_valid(_player.currently_grabbing)


func _find_closest_items() -> void:
	# Only test for if something is closer to the player grabbing if the player isn't already grabbing
	if not _is_already_grabbing:
		# Check if the building is the closest thing
		if (
				Nodes.world.buildings.size() >= 0 
				and _is_closest_building_valid
				and Building.closest_point_to_manipulator >= 0
		):
			var position_of_vertex: Vector3 = _closest_building_points[Building.closest_point_to_manipulator]
			_closest_found_thing_type = Player.Grabbable.VERTEX
			_closest_found_thing_distance = position_of_vertex.distance_squared_to(_player.point_manipulator.global_position)
			_selector_mesh.global_position = position_of_vertex
		
		# Check if the item selected is closer than the building
		if _is_selected_item_valid:
			var distance_to_item: float
			if _is_selected_item_grabbable:
				distance_to_item = _selected_item_to_grab.global_position.distance_squared_to(_player.point_manipulator.global_position)
			else:
				distance_to_item = _selected_item.global_position.distance_squared_to(_player.point_manipulator.global_position)
			if distance_to_item < _closest_found_thing_distance:
				_closest_found_thing_type = Player.Grabbable.ITEM
				_closest_found_thing_distance = distance_to_item
				if _is_selected_item_grabbable:
					_selector_mesh.global_position = _selected_item_to_grab.global_position
				else:
					_selector_mesh.global_position = _selected_item.global_position


func _move_grabbed_items() -> void:
	if Input.is_action_just_pressed(&"select"):
		match _closest_found_thing_type:
			Player.Grabbable.VERTEX:
				_closest_building.started_grabbing_this(Building.closest_point_to_manipulator)
				_player.currently_grabbing = _closest_building
			Player.Grabbable.ITEM:
				_selected_item.start_interacting_with()
				_player.currently_grabbing = _selected_item
	if Input.is_action_just_released(&"select"):
		if _player.currently_grabbing is BuildingNode:
			_player.currently_grabbing.stopped_grabbing_this()
		elif _player.currently_grabbing is ItemShape:
			_player.currently_grabbing.stop_interacting_with()
		_player.currently_grabbing = null
	
	if is_instance_valid(_selected_item) and _selected_item != _previous_closest_item:
		if is_instance_valid(_previous_closest_item):
			_previous_closest_item.no_longer_closest_item_to_selector()
		_selected_item.closest_item_to_selector()
		_previous_closest_item = _selected_item
	elif _closest_found_thing_type != Player.Grabbable.ITEM and is_instance_valid(_previous_closest_item):
		_previous_closest_item.no_longer_closest_item_to_selector()
		_previous_closest_item = null
	
	if not is_instance_valid(_player.currently_grabbing):
		match _closest_found_thing_type:
			Player.Grabbable.NOTHING:
				Nodes.world.selector_mesh.global_position = _player.point_manipulator.global_position
			Player.Grabbable.ITEM:
				Nodes.world.selector_mesh.global_position = _selected_item.global_position
			Player.Grabbable.VERTEX:
				Nodes.world.selector_mesh.global_position = _closest_building_points[Building.closest_point_to_manipulator]
