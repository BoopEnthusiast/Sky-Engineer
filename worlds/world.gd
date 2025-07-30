class_name World
extends Node3D


const BUILDING = preload("res://interactibles/building.tscn")

var selected_inventory_slot: InventorySlot

@onready var buildings: Array[BuildingNode] = [$Building1]
@onready var selector_mesh: MeshInstance3D = $SelectorMesh


func _enter_tree() -> void:
	Nodes.world = self


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
