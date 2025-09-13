class_name InventoryCraftingCorner
extends Node3D


signal position_changed(corner: InventoryCraftingCorner)

@onready var meshes: Array[MeshInstance3D] = [$X, $Y, $Z]


func _set(property: StringName, value: Variant) -> bool:
	if property == "global_position":
		var rot := rotation
		global_position = value
		rotation = rot
		position_changed.emit(self)
		return true
	return false
