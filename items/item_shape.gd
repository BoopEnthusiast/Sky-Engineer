@tool
class_name ItemShape
extends Area3D


signal being_put_into_inventory()
signal being_taken_from_inventory()


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
@export var item_to_grab: Node3D

@onready var _collider: CollisionShape3D = $Collider
