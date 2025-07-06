class_name Menu
extends Node


const LERP_SPEED = 8.0

@onready var menu_3d: Node3D = $Menu3D
@onready var menu_2d: Control = $Menu2D

@onready var counters: Counters = $Counters


func _enter_tree() -> void:
	Nodes.menu = self


func _ready() -> void:
	menu_2d.visible = false


func _process(delta: float) -> void:
	# Move and turn menu_3d to active camera
	var weight = 1 - exp(-LERP_SPEED * delta) # Makes it framerate-independent like it says in:
	# https://docs.godotengine.org/en/stable/tutorials/math/interpolation.html#smoothing-motion
	# Move and turn to player's camera
	var main_camera = get_viewport().get_camera_3d()
	menu_3d.global_position = menu_3d.global_position.lerp(main_camera.global_position, weight)
	menu_3d.global_basis = menu_3d.global_basis.slerp(main_camera.global_basis, weight)
	
	# Open and close the inventory
	if Input.is_action_just_pressed(&"open_inventory"):
		pass
