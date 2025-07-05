class_name Inventory
extends Node3D


@export var always_visible: Array[Node]
@export var inventory_only: Array[Node]

var vertices_left: int = 5:
	set(value):
		vertices_left = value
		vertices.mesh.text = str(value)

@onready var vertices: MeshInstance3D = $Counters/Vertices


func _enter_tree() -> void:
	Nodes.inventory = self
