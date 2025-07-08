class_name InventorySlot
extends Area3D


@export var item: Item:
	set(value):
		item = value
		item.updated_polygon.connect(_item_updated_polygon)

@onready var mesh: CSGPolygon3D = $Mesh


func _item_updated_polygon() -> void:
	mesh.polygon = item.polygon
