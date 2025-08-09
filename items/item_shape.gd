@tool
class_name ItemShape
extends Area3D


signal put_into_inventory()
signal taken_from_inventory()


@export var can_be_grabbed: bool = true:
	set(value):
		can_be_grabbed = value
		monitorable = value
		if is_instance_valid(Nodes.player):
			if not value and Nodes.player.currently_grabbing == self:
				Nodes.player.currently_grabbing = null
@export var grab_range: float = 0.5:
	set(value):
		grab_range = value
		if not is_node_ready():
			await ready
		_collider.shape.radius = value
@export var grab_weight: float = 4.0
@export var item_to_grab: Node3D

var is_currently_grabbed := false

@onready var _collider: CollisionShape3D = $Collider


func put_item_into_inventory(inventory_slot: InventorySlot) -> void:
	can_be_grabbed = false
	put_into_inventory.emit()
	inventory_slot.currently_held_item = self
	item_to_grab.get_parent().remove_child(item_to_grab)
	inventory_slot.add_child(item_to_grab)
	item_to_grab.position = Vector3.ZERO


func take_item_from_inventory(inventory_slot: InventorySlot) -> void:
	can_be_grabbed = true
	taken_from_inventory.emit()
	inventory_slot.currently_held_item = null
	var previous_global_position := item_to_grab.global_position
	var parent := item_to_grab.get_parent()
	if parent is InventorySlot:
		parent.remove_child(item_to_grab)
		Nodes.world.add_child(item_to_grab)
	item_to_grab.global_position = previous_global_position
