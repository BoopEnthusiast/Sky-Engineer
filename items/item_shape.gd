@tool
class_name ItemShape
extends Area3D
## Component scene meant to be added as a child of any items
##
## Add the item_shape.tscn scene as a child of any items the player should be able to interact with.
## Then, set the [member item_to_grab] to the relevant node of your scene that the player should move (usually the root node).


## Emitted just after the item is put into the inventory.
signal put_into_inventory()
## Emitted just after the item is taken out of the inventory.
signal taken_from_inventory()
## Emitted when this is the closest item to the player's 3D cursor.[br]
## [br]
## This is not emitted when [member outline_when_grabbed] is set.
signal closest_item_to_grab()
## Emitted when this is no longer the closest item to the player's 3D cursor.[br]
## [br]
## This is not emitted when [member outline_when_grabbed] is set.
signal no_longer_closest_item_to_grab()


## This must be set for this node to work, there is an assert to make sure that this is set when the game is run
@export var item_to_grab: Node3D
## Decides if the player can pick up this item by looking at it.[br]
## It's set to true or false automatically when it enters or exists the inventory, respectively.
@export var can_be_grabbed: bool = true:
	set(value):
		can_be_grabbed = value
		monitorable = value
		if is_instance_valid(Nodes.player):
			if not value and Nodes.player.currently_grabbing == self:
				Nodes.player.currently_grabbing = null
## Sets the size of the collider of the sphere that checks if the player can grab it or not.
@export var grab_range: float = 0.5:
	set(value):
		grab_range = value
		if not is_node_ready():
			await ready
		_collider.shape.radius = value
## Sets how fast this item should follows the player's 3D cursor
@export var grab_weight: float = 4.0
## If this is set, it will add a material to the next pass of the presumed [PrimitiveMesh] of every [MeshInstance3D] added here.[br]
## [br]
## Does not emit [signal closest_item_to_grab] and [signal no_longer_closest_item_to_grab] when this has at least one thing set.
@export var outline_when_grabbed: Array[MeshInstance3D]

var is_currently_grabbed := false

@onready var _collider: CollisionShape3D = $Collider


func _ready() -> void:
	# This is only code for in the game, not the editor
	if Engine.is_editor_hint():
		return
	
	assert(not is_instance_valid(item_to_grab), "An item does not have its item_to_grab set, update this assert to say which if you can't find it")
	
	# Make sure the item_to_grab is ready
	if not item_to_grab.is_node_ready():
		await item_to_grab.ready


## Do most of the things required to put the item into the [Inventory], including moving the [member item_to_grab] to the [param inventory_slot].
func put_item_into_inventory(inventory_slot: InventorySlot) -> void:
	can_be_grabbed = false
	inventory_slot.currently_held_item = self
	item_to_grab.get_parent().remove_child(item_to_grab)
	inventory_slot.add_child(item_to_grab)
	item_to_grab.position = Vector3.ZERO
	put_into_inventory.emit()


## Do most of the things required to take the item from the [Inventory], including moving the [member item_to_grab] from the [param inventory_slot] to the world.
func take_item_from_inventory(inventory_slot: InventorySlot) -> void:
	can_be_grabbed = true
	inventory_slot.currently_held_item = null
	var previous_global_position := item_to_grab.global_position
	var parent := item_to_grab.get_parent()
	if parent is InventorySlot:
		parent.remove_child(item_to_grab)
		Nodes.world.add_child(item_to_grab)
	item_to_grab.global_position = previous_global_position
	taken_from_inventory.emit()


## Handles the outlining of the [member outline_when_grabbed] or emits [signal closest_item_to_grab].
func closest_item_to_selector() -> void:
	pass


## Handles removing the outlines from [member outline_when_grabbed] or emits [signal no_longer_closest_item_to_grab].
func no_longer_closest_item_to_selector() -> void:
	pass
