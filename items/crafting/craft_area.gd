@tool
class_name CraftArea
extends AnimatableBody3D


@export var shape: Shape3D:
	set(value):
		if not is_node_ready():
			await ready
		if not _collider.is_node_ready():
			await _collider.ready
		_collider.shape = value
	get():
		return _collider.shape

@onready var _collider: CollisionShape3D = $Collider
