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

const OUTLINE = preload("res://interactibles/item_components/outline.tres")

## Decides if the player can pick up this item by looking at it.[br]
## It's set to true or false automatically when it enters or exists the inventory, respectively.
@export var can_be_interacted_with: bool = true:
	set(value):
		can_be_interacted_with = value
		monitorable = value
		if not Engine.is_editor_hint():
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
@export_category("Outline meshes")
## If this is set, it will add a material to the next pass of the presumed [PrimitiveMesh] of every [MeshInstance3D] added here.[br]
## [br]
## Does not emit [signal closest_item_to_grab] and [signal no_longer_closest_item_to_grab] when this has at least one thing set.
@export var outline_when_interactible: Array[MeshInstance3D]
## The color of the outline of meshes in [member outline_when_interactible].
@export var outline_color: Color = Color.WHITE
## The outline threshold for the meshes in [member outline_when_interactible].
@export var outline_threshold: float = 0.2

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
	
	var outline_material = OUTLINE.duplicate()
	outline_material.set_shader_parameter(&"outline_color", outline_color)
	outline_material.set_shader_parameter(&"outline_threshold", outline_threshold)
	
	for to_outline: MeshInstance3D in outline_when_interactible:
		if not is_instance_valid(to_outline):
			continue
		if not is_instance_valid(to_outline.mesh):
			push_warning("Node at " + to_outline.get_path().get_concatenated_names() + " does not have a mesh but is marked by an ItemShape to be outlined")
			continue
		if to_outline.mesh is not PrimitiveMesh:
			push_warning("Node at " + to_outline.get_path().get_concatenated_names() + " has a mesh other than a PrimitiveMesh but is marked by an ItemShape to be outlined")
			continue
		var mesh: PrimitiveMesh = to_outline.mesh
		if not is_instance_valid(mesh.material):
			push_warning("Node at " + to_outline.get_path().get_concatenated_names() + " does not have a material but is marked by an ItemShape to be outlined. Give it a StandardMaterial3D.")
			mesh.material = StandardMaterial3D.new()
		var material: Material = mesh.material
		var next_pass: Material = material.next_pass
		while is_instance_valid(next_pass) and next_pass is not ShaderMaterial:
			material = material.next_pass
			next_pass = material.next_pass
		material.next_pass = outline_material.duplicate()


## Handles removing the outlines from [member outline_when_grabbed] or emits [signal no_longer_closest_item_to_grab].
func no_longer_closest_item_to_selector() -> void:
	if outline_when_interactible.size() == 0:
		no_longer_closest_item_to_interact_with.emit()
		return
	
	for to_outline: MeshInstance3D in outline_when_interactible:
		if not is_instance_valid(to_outline):
			continue
		if not is_instance_valid(to_outline.mesh):
			push_warning("Node at " + to_outline.get_path().get_concatenated_names() + " does not have a mesh but is marked by an ItemShape to be outlined")
			continue
		if to_outline.mesh is not PrimitiveMesh:
			push_warning("Node at " + to_outline.get_path().get_concatenated_names() + " has a mesh other than a PrimitiveMesh but is marked by an ItemShape to be outlined")
			continue
		var mesh: PrimitiveMesh = to_outline.mesh
		if not is_instance_valid(mesh.material):
			push_warning("Node at " + to_outline.get_path().get_concatenated_names() + " does not have a material but is marked by an ItemShape to be outlined. Give it a StandardMaterial3D.")
			mesh.material = StandardMaterial3D.new()
		var material: Material = mesh.material
		var next_pass: Material = material.next_pass
		# This is not good of a way to do it because we could write our own shaders and have the outline as a next pass on top of those but I'm not sure how else to check it
		while is_instance_valid(next_pass) and next_pass is not ShaderMaterial:
			material = material.next_pass
			next_pass = material.next_pass
		material.next_pass = null
