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

const ROTATION_SLOW = 300.0

## This must be set for this node to work, there is an assert to make sure that this is set when the game is run.
@export var item_to_grab: Node3D
## If this item can be grabbed.
@export var can_be_grabbed := true:
	set(value):
		if not value:
			is_currently_grabbed = false
		can_be_grabbed = value
## Sets how fast this item should follows the player's 3D cursor.
@export var grab_weight: float = 4.0
## If the player can turn this item or not.
@export var can_be_rotated: bool = true:
	set(value):
		if not value:
			is_being_rotated = false
		can_be_rotated = value
## Determines fast the player rotates this item. Larger numbers slow rotation.
@export var rotation_speed: float = 4.0

## Whether this item is currently grabbed or not.
var is_currently_grabbed := false
## Whether this item is currently being rotated or not.
var is_being_rotated := false

var _basis_to_turn_to: Basis


func _ready() -> void:
	# This is only code for in the game, not the editor
	if Engine.is_editor_hint():
		return
	
	assert(is_instance_valid(item_to_grab), "The item: " + get_parent().name + " does not have its item_to_grab set. Node at: " + get_path().get_concatenated_names())
	
	if item_to_grab is AnimatableBody3D:
		item_to_grab.sync_to_physics = false


func _unhandled_input(event: InputEvent) -> void:
	# Rotate if being rotated
	if is_being_rotated and event is InputEventMouseMotion:
		_basis_to_turn_to = _basis_to_turn_to.rotated(Nodes.player.camera.global_basis.x, event.relative.y / ROTATION_SLOW)
		_basis_to_turn_to = _basis_to_turn_to.rotated(Nodes.player.camera.global_basis.y, event.relative.x / ROTATION_SLOW)
		get_viewport().set_input_as_handled()


func _physics_process(delta):
	if is_currently_grabbed:
		if Input.is_action_just_pressed(&"color") and can_be_rotated:
			is_being_rotated = true
			Nodes.player.mouse_captured = false
			_basis_to_turn_to = item_to_grab.basis
		elif Input.is_action_just_released(&"color") and is_being_rotated:
			is_being_rotated = false
			Nodes.player.mouse_captured = true
		
		var weight: float = 1 - exp(-grab_weight * delta)
		item_to_grab.global_position = item_to_grab.global_position.lerp(Nodes.player.point_manipulator.global_position, weight)
		Nodes.world.selector_mesh.global_position = global_position
		
		if is_being_rotated:
			weight = 1 - exp(-rotation_speed * delta)
			item_to_grab.basis = item_to_grab.basis.slerp(_basis_to_turn_to, weight)


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
	if is_being_rotated:
		is_being_rotated = false
		Nodes.player.mouse_captured = true
