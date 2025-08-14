@tool
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

## This must be set for this node to work, there is an assert to make sure that this is set when the game is run.
@export var item_to_grab: Node3D
## Sets how fast this item should follows the player's 3D cursor.
@export var grab_weight: float = 4.0

## Whether this item is currently grabbed or not.
var is_currently_grabbed := false


func _ready() -> void:
	# This is only code for in the game, not the editor
	if Engine.is_editor_hint():
		return
	
	assert(is_instance_valid(item_to_grab), "The item: " + get_parent().name + " does not have its item_to_grab set. Node at: " + get_path().get_concatenated_names())


func _physics_process(delta):
	if is_currently_grabbed:
		var weight: float = 1 - exp(-grab_weight * delta)
		item_to_grab.global_position = item_to_grab.global_position.lerp(Nodes.player.point_manipulator.global_position, weight)
		Nodes.world.selector_mesh.global_position = global_position


## Do most of the things required to put the item into the [Inventory], including moving the [member item_to_grab] to the [param inventory_slot].
func put_item_into_inventory(inventory_slot: InventorySlot) -> void:
	can_be_interacted_with = false
	is_currently_grabbed = false
	inventory_slot.currently_held_item = self
	item_to_grab.get_parent().remove_child(item_to_grab)
	inventory_slot.add_child(item_to_grab)
	item_to_grab.position = Vector3.ZERO
	put_into_inventory.emit()


## Do most of the things required to take the item from the [Inventory], including moving the [member item_to_grab] from the [param inventory_slot] to the world.
func take_item_from_inventory(inventory_slot: InventorySlot) -> void:
	can_be_interacted_with = true
	is_currently_grabbed = true
	inventory_slot.currently_held_item = null
	var previous_global_position := item_to_grab.global_position
	var parent := item_to_grab.get_parent()
	if parent is InventorySlot:
		parent.remove_child(item_to_grab)
		Nodes.world.add_child(item_to_grab)
	item_to_grab.global_position = previous_global_position
	taken_from_inventory.emit()


## Call when started being grabbed by the player
func start_interacting_with() -> void:
	grabbed_by_player.emit()
	is_currently_grabbed = true


## Call when stopped being grabbed by the player
func stop_interacting_with() -> void:
	no_longer_grabbed_by_player.emit()
	is_currently_grabbed = false
