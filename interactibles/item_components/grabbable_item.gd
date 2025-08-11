class_name GrabbableItem
extends ItemShape


## Emitted just after the item is put into the inventory.
signal put_into_inventory()
## Emitted just after the item is taken out of the inventory.
signal taken_from_inventory()
## Emitted when the item has been grabbed by the player.
signal grabbed_by_player()
## Emitted when the item is no longer being grabbed by the player.
signal no_longer_grabbed_by_player()

## Sets how fast this item should follows the player's 3D cursor
@export var grab_weight: float = 4.0


## Do most of the things required to put the item into the [Inventory], including moving the [member item_to_grab] to the [param inventory_slot].
func put_item_into_inventory(inventory_slot: InventorySlot) -> void:
	can_be_interacted_with = false
	inventory_slot.currently_held_item = self
	item_to_grab.get_parent().remove_child(item_to_grab)
	inventory_slot.add_child(item_to_grab)
	item_to_grab.position = Vector3.ZERO
	put_into_inventory.emit()


## Do most of the things required to take the item from the [Inventory], including moving the [member item_to_grab] from the [param inventory_slot] to the world.
func take_item_from_inventory(inventory_slot: InventorySlot) -> void:
	can_be_interacted_with = true
	inventory_slot.currently_held_item = null
	var previous_global_position := item_to_grab.global_position
	var parent := item_to_grab.get_parent()
	if parent is InventorySlot:
		parent.remove_child(item_to_grab)
		Nodes.world.add_child(item_to_grab)
	item_to_grab.global_position = previous_global_position
	taken_from_inventory.emit()


## Call when the player grabs this item
func player_grabs_this() -> void:
	grabbed_by_player.emit()


## Call when the player stops grabbing this item
func player_stops_grabbing_this() -> void:
	no_longer_grabbed_by_player.emit()
