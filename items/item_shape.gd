@tool
class_name ItemShape
extends Area3D


signal put_into_inventory()
signal taken_from_inventory()


@export var can_be_grabbed: bool = true:
	set(value):
		can_be_grabbed = value
		monitorable = value
@export var grab_range: float = 0.5:
	set(value):
		grab_range = value
		if not is_node_ready():
			await ready
		_collider.shape.radius = value
@export var grab_weight: float = 4.0
@export var item_to_grab: Node3D

@onready var _collider: CollisionShape3D = $Collider


func put_item_into_inventory() -> void:
	put_into_inventory.emit()


func take_item_from_inventory() -> void:
	taken_from_inventory.emit()
