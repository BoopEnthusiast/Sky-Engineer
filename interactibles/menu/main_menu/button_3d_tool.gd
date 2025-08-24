@tool
extends Button3D


## Changes the displayed text on this [Button3D].
@export var text: String = "":
	set(value):
		text = value
		if not is_node_ready():
			await ready
		_text_mesh.mesh.text = value
## Changes the size of the box mesh/collider on this [Button3D].
@export var size: Vector3 = Vector3.ONE:
	set(value):
		size = value
		if not is_node_ready():
			await ready
		_mesh.mesh.size = value
		_collider.shape.size = value
		_text_mesh.position.z = value.z / 2 + _text_mesh.mesh.depth / 2


@onready var _mesh: MeshInstance3D = $StaticBody/Mesh
@onready var _collider: CollisionShape3D = $StaticBody/Collider
@onready var _text_mesh: MeshInstance3D = $StaticBody/TextMesh


func _ready() -> void:
	_mesh.mesh = _mesh.mesh.duplicate(true)
	_collider.shape = _collider.shape.duplicate(true)
	_text_mesh.mesh = _text_mesh.mesh.duplicate(true)
	
	if not Engine.is_editor_hint():
		super()


func _process(delta: float) -> void:
	if not Engine.is_editor_hint():
		super(delta)
