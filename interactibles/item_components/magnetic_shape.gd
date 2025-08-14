@tool
class_name MagneticShape
extends Area3D
## An [Area3D] scene that pulls in other magnetic items.
## 
## It's an [Area3D] that detects other [MageneticShape] components and pulls in their [member item_to_pull].


## The item to be pulled in by other [MagneticShape]s.
@export var item_to_be_pulled: Node3D
## If this [MagneticShape] is working or not.
@export var is_pulling_in: bool = true
## How much force it pulls in other [MagneticShape]s.
@export var pull_force: float = 5.0
## The group that it filters what it pulls in.
## Other [MagneticShape]s must have this group if the item is to be pulled.
@export var group_filter: StringName = "Magnetic"
## Sets the size of the collider of the outer-range of this node.
@export var pull_range: float = 0.5:
	set(value):
		pull_range = value
		if not is_node_ready():
			await ready
		_collider.shape.radius = value

var _magnetic_shapes_inside: Array[MagneticShape]
var _pull_range_sq: float:
	get:
		return pow(pull_range * 2, 2)

@onready var _collider: CollisionShape3D = $Collider


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	assert(is_instance_valid(item_to_be_pulled), "The item: " + get_parent().name + " does not have its item_to_pull set. Node at: " + get_path().get_concatenated_names())


func _physics_process(delta: float) -> void:
	if not is_pulling_in:
		return
	
	for shape: MagneticShape in _magnetic_shapes_inside:
		var distance: float = shape.item_to_be_pulled.global_position.distance_squared_to(global_position)
		var pull_weight: float = max(0, (_pull_range_sq - distance) / _pull_range_sq) * pull_force
		var weight: float = 1 - exp(-pull_weight * delta)
		shape.item_to_be_pulled.global_position = shape.item_to_be_pulled.global_position.lerp(global_position, weight)


func _on_area_entered(area: Area3D) -> void:
	if area is MagneticShape:
		if area.is_in_group(group_filter):
			_magnetic_shapes_inside.append(area)


func _on_area_exited(area: Area3D) -> void:
	_magnetic_shapes_inside.erase(area)
