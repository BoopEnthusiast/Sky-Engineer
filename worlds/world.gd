class_name World
extends Node3D


const BUILDING = preload("res://interactibles/building.tscn")

var currently_selected_building: int
var currently_selected_point: int

@onready var buildings: Array[BuildingNode] = [$Building]

@onready var selector_mesh: SelectorMesh = $SelectorMesh


func _enter_tree() -> void:
	Nodes.world = self


func _process(_delta: float) -> void:
	if (
			buildings.size() <= 0 
			or Building.closest_building_to_manipulator == -1
			or Building.closest_point_to_manipulator < 0
	):
		selector_mesh.global_position = Nodes.player.point_manipulator.global_position
	else:
		selector_mesh.global_position = buildings[Building.closest_building_to_manipulator].points[Building.closest_point_to_manipulator]


func create_new_building(starting_point: Vector3) -> void:
	var new_building = BUILDING.instantiate()
	new_building.points = [starting_point]
	new_building.colors = [Color.from_ok_hsl(randf(), 1.0, 0.8)]
	buildings.append(new_building)
	_update_building_indices()
	add_child(new_building)


func remove_building(building: BuildingNode) -> void:
	buildings.erase(building)
	_update_building_indices()


func _update_building_indices() -> void:
	for i: int in range(buildings.size()):
		buildings[i].building_index = i
