@tool
class_name CraftArea
extends Area3D
## A basic area that has a lot of available features for letting the player craft by putting items in a set area.


## Emitted when the crafting is finished.
signal finished_crafting(scene: PackedScene)
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
## If this [CraftArea] should display [member progress_bar] of how close the item is to being made.
@export var display_progress_bar := true:
	set(value):
		if not is_node_ready():
			await ready
		progress_bar.visible = value
		display_progress_bar = value

## The various recipe lists this [CraftArea] checks for matching recipes to the nodes inside of it.
var recipe_lists: Array[Dictionary]
## The nodes that are inside this [CraftArea].
var nodes_inside: Array[Node3D]

var _update_thread: Thread
var _update_semaphore: Semaphore
var _update_mutex: Mutex
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
	_update_thread = Thread.new()
	_update_semaphore = Semaphore.new()
	_update_mutex = Mutex.new()


func _process(_delta: float) -> void:
	progress_bar.value = crafting_timer.wait_time - crafting_timer.time_left


func _exit_tree() -> void:
	_update_thread.wait_to_finish()


## Adds a recipe list. This recipe should be a recipe list from the [code]recipes.gd[/code]/[code]Recipes[/code] singleton.
func add_recipe_list(list: Dictionary) -> void:
	recipe_lists.append(list)


## Starts the process of crafting, which either is instant or after the [member crafting_timer] times out depending on [member instant_crafting].
func start_crafting() -> void:
	_update_if_should_craft()
	if _to_craft == null:
		return
	
	if instant_crafting:
		_craft()
		finished_crafting.emit(_to_craft)
	else:
		if crafting_timer.is_stopped():
			crafting_timer.start()
			started_crafting.emit()


## Cancels crafting if [member instant_crafting] is not enabled and this [CraftArea] is currently crafting.
func cancel_crafting() -> void:
	if not crafting_timer.is_stopped():
		crafting_timer.stop()


## Changes the wait time for [member crafting_timer] and the max value for [member progress_bar].
func change_wait_time(time: float) -> void:
	crafting_timer.wait_time = time
	progress_bar.max_value = time


func _craft() -> void:
	pass


func _update_if_should_craft() -> bool:
	# TODO: make this function
	
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
	else:
		_update_if_should_craft()
		if _to_craft == null:
			cancel_crafting()


func _on_crafting_timeout() -> void:
	_craft()
	finished_crafting.emit(_to_craft)
