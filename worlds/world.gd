class_name World
extends Node3D


const BUILDING = preload("res://interactibles/building.tscn")

var building_count: int = 1

func _enter_tree() -> void:
	Nodes.world = self


func create_new_building(starting_point: Vector3) -> void:
	var new_building = BUILDING.instantiate()
	new_building.points = [starting_point]
	new_building.colors = [Color.from_ok_hsl(randf(), 1.0, 0.8)]
	new_building.building_index = building_count
	add_child(new_building)
	building_count += 1


func remove_building() -> void:
	building_count -= 1
