class_name InventoryCraftingCorner
extends Node3D


signal position_changed(corner: InventoryCraftingCorner)

var index: Vector3i

@onready var meshes: Array[MeshInstance3D] = [$X, $Y, $Z]


func _set(property: StringName, value: Variant) -> bool:
	if property == "global_position":
		global_position = value
		position_changed.emit(self)
		return true
	return false
