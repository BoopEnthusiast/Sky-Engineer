@tool
class_name CraftArea
extends Area3D
## A basic area that has a lot of available features for letting the player craft by putting items in a set area.


## Emitted when the crafting is finished.
signal finished_crafting(new_node: Node)
## Emitted when the crafting starts.[br]
## [br]
## It is not emitted when [member instant_crafting] is enabled.
signal started_crafting()

## The collision shape of this [CraftArea].
@export var shape: Shape3D:
	set(value):
		if not is_node_ready():
			await ready
		if not _collider.is_node_ready():
			await _collider.ready
		_collider.shape = value
	get():
		if not is_node_ready():
			await ready
		if not _collider.is_node_ready():
			await _collider.ready
		return _collider.shape
## If this [CraftArea] immediatly starts crafting when all necessary items for a craft are in the area,
## or if it should wait until [member crafting_timer] times out.
@export var instant_crafting := false
## If this [CraftArea] should display [member progress_bar] of how close the item is to being made.[br]
## [br]
## It is made invisible when the game starts. You should probably leave this true.
@export var display_progress_bar_sprite := true:
	set(value):
		if not is_node_ready():
			await ready
		progress_bar_sprite.visible = value
		display_progress_bar_sprite = value
## How high the progress bar is from the center of the node.
@export var progress_bar_sprite_height := 2.0:
	set(value):
		if not is_node_ready():
			await ready
		if not progress_bar_sprite.is_node_ready():
			await progress_bar_sprite.ready
		progress_bar_sprite_height = value
		progress_bar_sprite.position.y = value
## How long it takes to craft, assuming [member instant_crafting] is false.
@export var wait_time := 3.0:
	set(value):
		if not is_node_ready():
			await ready
		crafting_timer.wait_time = value
		progress_bar.max_value = value
		wait_time = value

## The various recipe lists this [CraftArea] checks for matching recipes to the nodes inside of it.
var recipe_lists: Array[Dictionary]
## The nodes that are inside this [CraftArea].
var nodes_inside: Array[Node3D]

var _nodes_used_to_craft: Array[Node3D]
var _to_craft: PackedScene

## The [Timer] node used for crafting if [member instant_crafting] is true.[br]
## [br]
## Instead of changing this timer's [member Timer.wait_time] manually, use [method change_wait_time].
@onready var crafting_timer: Timer = $Crafting
## The progress bar displaying [member crafting_timer].
@onready var progress_bar: ProgressBar = $SubViewport/ProgressBar
## The [SubViewport] containing [member progress_bar].
@onready var sub_viewport: SubViewport = $SubViewport
## The [Sprite3D] display of [member progress_bar].
@onready var progress_bar_sprite: Sprite3D = $ProgressBar

@onready var _collider: CollisionShape3D = $Collider


func _ready() -> void:
	wait_time = wait_time
	if Engine.is_editor_hint():
		progress_bar_sprite.visible = display_progress_bar_sprite
	else:
		progress_bar_sprite.visible = false


func _process(_delta: float) -> void:
	progress_bar.value = crafting_timer.wait_time - crafting_timer.time_left


## Adds a recipe list. This recipe should be a recipe list from the [code]recipes.gd[/code]/[code]Recipes[/code] singleton.
func add_recipe_list(list: Dictionary) -> void:
	recipe_lists.append(list)


## Starts the process of crafting, which either is instant or after the [member crafting_timer] times out depending on [member instant_crafting].
func start_crafting() -> void:
	if not is_visible_in_tree() or not _update_if_should_craft():
		return
	
	if instant_crafting:
		finished_crafting.emit(_craft())
	else:
		if crafting_timer.is_stopped():
			crafting_timer.start()
			progress_bar_sprite.visible = true
			started_crafting.emit()


## Cancels crafting if [member instant_crafting] is not enabled and this [CraftArea] is currently crafting.
func cancel_crafting() -> void:
	if not crafting_timer.is_stopped():
		progress_bar_sprite.visible = false
		crafting_timer.stop()


func _craft() -> Node:
	for node: Node3D in _nodes_used_to_craft:
		node.queue_free()
	var new_node := _to_craft.instantiate()
	Nodes.world.add_child(new_node)
	progress_bar_sprite.visible = false
	return new_node


func _update_if_should_craft() -> bool:
	# Get the available groups on all the nodes inside this craft area and the list of nodes that have them
	var available_groups: Dictionary[StringName, Array]
	for node: Node3D in nodes_inside:
		for node_group: StringName in node.get_groups():
			# Ignore internal groups (like those from the editor)
			if node_group.begins_with("_"):
				continue
			if available_groups.has(node_group):
				available_groups[node_group].append(node)
			else:
				available_groups[node_group] = [node]
	
	# For each list available to this craft area
	for recipe_list: Dictionary[Dictionary, PackedScene] in recipe_lists:
		# Get each recipe dictionary
		for recipe: Dictionary[StringName, int] in recipe_list:
			# Check if this recipe has all the requisite groups and enough items to make it
			var has_all_requirements := recipe.size() > 0
			var required_nodes: Array[Node3D]
			for key: StringName in recipe:
				if available_groups.has(key):
					if available_groups[key].size() >= recipe[key]:
						# Add only the required amount of nodes to the required nodes in case there's more than the required amount
						for i: int in range(recipe[key]):
							required_nodes.append(available_groups[key][i])
					else:
						has_all_requirements = false
						break
				else:
					has_all_requirements = false
					break
			# Found a matching recipe! Set private variables and return true
			if has_all_requirements:
				_nodes_used_to_craft = required_nodes
				_to_craft = recipe_list[recipe]
				return true
	return false


func _on_node_entered(node: Node3D) -> void:
	nodes_inside.append(node)
	_check_crafting_state()


func _on_node_exited(node: Node3D) -> void:
	nodes_inside.erase(node)
	_check_crafting_state()


func _check_crafting_state() -> void:
	if crafting_timer.is_stopped():
		start_crafting()
	elif not is_visible_in_tree() or not _update_if_should_craft():
		cancel_crafting()


func _on_crafting_timeout() -> void:
	if is_visible_in_tree():
		finished_crafting.emit(_craft())
