class_name Inventory
extends Node


const LERP_SPEED = 8.0

@onready var inventory_3d: Node3D = $Inventory3D
@onready var inventory_2d: Control = $Inventory2D
@onready var reference_camera: Camera3D = $ReferenceCamera
@onready var counters: Counters = $Counters


func _enter_tree() -> void:
	Nodes.inventory = self


func _process(delta: float) -> void:
	# Move inventory_3d to active camera
	var weight = 1 - exp(-LERP_SPEED * delta) # Makes it framerate-dependent like it says in:
	# https://docs.godotengine.org/en/stable/tutorials/math/interpolation.html#smoothing-motion
	var main_camera = get_viewport().get_camera_3d()
	# Move to player's camera
	inventory_3d.global_position = inventory_3d.global_position.lerp(main_camera.global_position, weight)
	# Turn to player's camera
	inventory_3d.global_basis = inventory_3d.global_basis.slerp(main_camera.global_basis, weight)
