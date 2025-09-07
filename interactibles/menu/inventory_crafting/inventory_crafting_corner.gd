class_name InventoryCraftingCorner
extends Node3D


signal position_changed(corner: InventoryCraftingCorner)

@onready var x: MeshInstance3D = $X
@onready var y: MeshInstance3D = $Y
@onready var z: MeshInstance3D = $Z


func _set(property: StringName, value: Variant) -> bool:
	if property == "global_position":
		global_position = value
		position_changed.emit(self)
		return true
	return false
