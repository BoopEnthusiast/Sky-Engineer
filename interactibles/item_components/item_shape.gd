@tool
class_name ItemShape
extends Area3D
## Component scene meant to be added as a child of any items
##
## Add the item_shape.tscn scene as a child of any items the player should be able to interact with.
## Then, set the [member item_to_grab] to the relevant node of your scene that the player should move (usually the root node).


## Emitted when this is the closest item to the player's 3D cursor.[br]
## [br]
## This is not emitted when [member outline_when_grabbed] is set.
signal closest_item_to_interact_with()
## Emitted when this is no longer the closest item to the player's 3D cursor.[br]
## [br]
## This is not emitted when [member outline_when_grabbed] is set.
signal no_longer_closest_item_to_interact_with()


## Decides if the player can pick up this item by looking at it.[br]
## It's set to true or false automatically when it enters or exists the inventory, respectively.
@export var can_be_interacted_with: bool = true:
	set(value):
		can_be_interacted_with = value
		monitorable = value
		if is_instance_valid(Nodes.player):
			if not value and Nodes.player.currently_grabbing == self:
				Nodes.player.currently_grabbing = null
## Sets the size of the collider of the sphere that checks if the player can grab it or not.
@export var interact_range: float = 0.5:
	set(value):
		interact_range = value
		if not is_node_ready():
			await ready
		_collider.shape.radius = value
## If this is set, it will add a material to the next pass of the presumed [PrimitiveMesh] of every [MeshInstance3D] added here.[br]
## [br]
## Does not emit [signal closest_item_to_grab] and [signal no_longer_closest_item_to_grab] when this has at least one thing set.
@export var outline_when_interactible: Array[MeshInstance3D]

@onready var _collider: CollisionShape3D = $Collider


## Virtual function that should be handled by the child classes, which you should be using.[br]
## [br]
## Does nothing if it's not overwritten.
func start_interacting_with() -> void:
	pass


## Virtual function that should be handled by the child classes, which you should be using.[br]
## [br]
## Does nothing if it's not overwritten.
func stop_interacting_with() -> void:
	pass


## Handles the outlining of the [member outline_when_grabbed] or emits [signal closest_item_to_grab].
func closest_item_to_selector() -> void:
	if outline_when_interactible.size() == 0:
		closest_item_to_interact_with.emit()
		return


## Handles removing the outlines from [member outline_when_grabbed] or emits [signal no_longer_closest_item_to_grab].
func no_longer_closest_item_to_selector() -> void:
	if outline_when_interactible.size() == 0:
		closest_item_to_interact_with.emit()
		return
