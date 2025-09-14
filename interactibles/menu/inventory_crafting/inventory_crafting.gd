class_name InventoryCrafting
extends Node3D


const INVENTORY_CRAFTING_CORNER = preload("res://interactibles/menu/inventory_crafting/inventory_crafting_corner.tscn")

const LERP_SPEED = 10.0
const SIT_BELOW_INVENTORY_DISTANCE = 1.5

var corners: Array[InventoryCraftingCorner]
var shape: BoxShape3D

@onready var craft_area: CraftArea = $CraftArea


func _ready() -> void:
	assert(craft_area.shape is BoxShape3D, "The inventory crafting's area is not a box shape")
	shape = craft_area.shape
	
	for i: int in range(-1, 2, 2):
		for o: int in range(-1, 2, 2):
			for k: int in range(-1, 2, 2):
				var new_corner: InventoryCraftingCorner = INVENTORY_CRAFTING_CORNER.instantiate()
				add_child(new_corner)
				new_corner.index = Vector3i(i, o, k)
				
				new_corner.basis = new_corner.basis.rotated(Vector3.RIGHT, max(o, 0) * PI / 2)
				new_corner.basis = new_corner.basis.rotated(Vector3.UP, max(k, 0) * PI / 2)
				new_corner.basis = new_corner.basis.rotated(Vector3.BACK, max(i, 0) * PI / 2)
				if new_corner.index == Vector3i(1, 1, -1):
					new_corner.rotation = Vector3(0.0, -PI / 2, -PI / 2)
				if new_corner.index == Vector3i(1, 1, 1):
					new_corner.rotation = Vector3(0.0, -PI / 2, PI)
				
				new_corner.position_changed.connect(_on_corner_position_changed)
				corners.append(new_corner)
	_update_corner_positions()


func reset_position() -> void:
	global_position = Nodes.menu.inventory_position + Vector3.DOWN * SIT_BELOW_INVENTORY_DISTANCE


func _on_corner_position_changed(corner: InventoryCraftingCorner) -> void:
	var other_corner: InventoryCraftingCorner
	for corn: InventoryCraftingCorner in corners:
		if corn.index == -corner.index:
			other_corner = corn
			break
	shape.size = corner.position.abs() * 2
	global_position = other_corner.global_position.lerp(corner.global_position, 0.5)
	_update_corner_positions()


func _update_corner_positions() -> void:
	for corner: InventoryCraftingCorner in corners:
		corner.position = shape.size / 2 * Vector3(corner.index)
