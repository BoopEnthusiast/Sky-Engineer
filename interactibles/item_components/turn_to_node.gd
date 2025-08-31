@tool
class_name TurnToNode
extends Area3D
## This component turns [member item_to_rotate] towards a node when that node enters/exits this component.
##
## Attach the scene turn_to_node.tscn as a child of whatever node you want to rotate and set its various properties.
## Do not add this node just as a node without using the scene.

## Emitted when this component starts rotating [member item_to_rotate] towards the node.
signal started_rotating()
## Emitted when this component stops rotating [member item_to_rotate] towards the node.
signal stopped_rotating()

## How this node picks which node to follow.
enum HowToPickNode {
	PLAYER,
	GROUP,
	CLASS,
}

@export_category("Picking a node to turn toward")
## Sets how to pick the node that [member item_to_rotate] turns toward.
## This should not be changed during runtime because it is only checked when a node enters this component and not while it is inside.[br]
## [br]
## Player means it'll turn towards the player's camera.[br]
## Group means it'll use [member group_to_sort] to check if the node entering this component is part of that group.[br]
## Class means it'll use [member class_name_to_sort] to check if the node entering this component is part of that group.[br]
## [br]
## Make sure this component has the right collision mask set.
@export var how_to_pick_node := HowToPickNode.PLAYER
## If [member how_to_pick_node] is set to Group it'll check if the node entering this component is of the same group as written here.
@export var group_to_sort: StringName
## If [member how_to_pick_node] is set to Class then it'll check if the node entering this component is of the same class as written here.
@export var class_name_to_sort: String
## If this node checks for bodies or areas.
## True means it checks for bodies and false means it checks for areas.[br]
## Even if [member how_to_pick_node] is set to Player, it won't checks areas if they are the player because the player in this game is a body and not an area.
@export var check_for_bodies_not_areas := true
@export_category("Turning settings")
## The item this component will rotate.
@export var item_to_rotate: Node3D:
	set(value):
		var is_valid = is_instance_valid(value)
		# Remove the debug line if there's no item_to_rotate to
		if not is_valid and is_instance_valid(_debug_forward_line):
			_debug_forward_line.queue_free()
		# When this is set, set forward_direction to the forward direction of the item
		if is_valid and Engine.is_editor_hint():
			forward_direction = -value.basis.z
		# If it's during runtime, do not let this get set to null
		elif is_node_ready():
			return
		item_to_rotate = value
		notify_property_list_changed()
## Sets if this component turns [member item_to_rotate] to the node or not.
@export var turns_to_node := true:
	set(value):
		if not value:
			_node_turning_toward = null
		turns_to_node = value
		notify_property_list_changed()
## How far [TurnToNode] looks for the node.
@export var radius := 3.0:
	set(value):
		if not is_instance_valid(_collider):
			await ready
		if not _collider.is_node_ready():
			await _collider.ready
		_collider.shape.radius = value
		radius = value
		notify_property_list_changed()
## How fast it turns the [member item_to_rotate] towards the node.
@export var turn_speed := 5.0
## The direction that is considered forward that it'll rotate [member item_to_rotate] towards the node it should turn towards.
@export var forward_direction: Vector3:
	set(value):
		if not is_node_ready():
			await ready
		print(value,"\t\t",get_path().get_concatenated_names())
		print(get_stack())
		forward_direction = value.normalized()
		notify_property_list_changed()
## Shows the forward direction using a debug line or not.
@export var show_debug_forward_line := false:
	set(value):
		if not is_node_ready():
			await ready
		if not value:
			if is_instance_valid(_debug_forward_line):
				_debug_forward_line.queue_free()
		elif not is_instance_valid(_debug_forward_line) and is_instance_valid(item_to_rotate):
			_debug_forward_line = Debug.create_3d_line([item_to_rotate.global_position, item_to_rotate.global_position + forward_direction], Color.RED)
			_debug_forward_line.get_parent().remove_child(_debug_forward_line)
			add_child(_debug_forward_line)
		show_debug_forward_line = value
		notify_property_list_changed()


var _debug_forward_line: Debug3DLine
var _node_turning_toward: Node3D

@onready var _collider: CollisionShape3D = $Collider


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	# Hide the debug forward line in game
	#show_debug_forward_line = false
	
	assert(is_instance_valid(item_to_rotate), "The item: " + get_parent().name + " does not have its item_to_rotate set. Node at: " + get_path().get_concatenated_names())
	
	await get_tree().create_timer(5.0).timeout
	turns_to_node = true


func _process(_delta: float) -> void:
	if get_tree().get_frame() % 120 == 0 and not Engine.is_editor_hint(): print(is_instance_valid(_debug_forward_line),"\t\t",get_path().get_concatenated_names())
	if is_instance_valid(_debug_forward_line) and is_instance_valid(item_to_rotate):
		Debug.modify_3d_line(_debug_forward_line, [item_to_rotate.global_position, item_to_rotate.global_position + -Basis.looking_at(-forward_direction).z])
		_debug_forward_line.global_transform = Transform3D()


func _physics_process(delta: float) -> void:
	if not is_instance_valid(_node_turning_toward):
		return
	
	var weight: float = 1 - exp(-turn_speed * delta)
	var target_basis := Basis.looking_at(_node_turning_toward.global_position - item_to_rotate.global_position)
	var alignment_basis := Basis.looking_at(-forward_direction)
	item_to_rotate.basis = item_to_rotate.basis.slerp((target_basis * alignment_basis).orthonormalized(), weight)


func _on_body_entered(body: Node3D) -> void:
	if not check_for_bodies_not_areas or Engine.is_editor_hint() or not turns_to_node:
		return
	
	match how_to_pick_node:
		HowToPickNode.PLAYER:
			if body is Player:
				_node_turning_toward = body.camera
		HowToPickNode.GROUP:
			if body.is_in_group(group_to_sort):
				_node_turning_toward = body
		HowToPickNode.CLASS:
			if body.is_class(class_name_to_sort):
				_node_turning_toward = body
	
	if is_instance_valid(_node_turning_toward):
		started_rotating.emit()


func _on_body_exited(body: Node3D) -> void:
	if body == _node_turning_toward:
		_node_turning_toward = null
	elif body is Player:
		if body.camera == _node_turning_toward:
			_node_turning_toward = null
	
	if not is_instance_valid(_node_turning_toward):
		stopped_rotating.emit()


func _on_area_entered(area: Area3D) -> void:
	if check_for_bodies_not_areas or Engine.is_editor_hint() or not turns_to_node:
		return
	
	match how_to_pick_node:
		HowToPickNode.GROUP:
			if area.is_in_group(group_to_sort):
				_node_turning_toward = area
		HowToPickNode.CLASS:
			if area.is_class(class_name_to_sort):
				_node_turning_toward = area
	
	if is_instance_valid(_node_turning_toward):
		started_rotating.emit()


func _on_area_exited(area: Area3D) -> void:
	if area == _node_turning_toward:
		_node_turning_toward = null
		stopped_rotating.emit()
