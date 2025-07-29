@tool
class_name ItemShape
extends Area3D


@export var can_be_grabbed: bool = true:
	set(value):
		can_be_grabbed = value
		monitorable = value
@export var grab_range: float = 0.5:
	set(value):
		grab_range = value
		collider.shape.radius = value
@export var item_to_grab: Node

@onready var collider: CollisionShape3D = $Collider
