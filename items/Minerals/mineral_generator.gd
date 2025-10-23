class_name MineralGenerator
extends Node3D

@export_group("Mineral Scene Files")
@export_file("*.tscn") var jade_scene: String = "res://items/Minerals/Jade.tscn"
@export_file("*.tscn") var sapphire_scene: String = "res://items/Minerals/Sapphire.tscn"
@export_file("*.tscn") var ruby_scene: String = "res://items/Minerals/Ruby.tscn"
@export_file("*.tscn") var iron_scene: String = "res://items/Minerals/Iron.tscn"
@export_file("*.tscn") var copper_scene: String = "res://items/Minerals/Copper.tscn"

@export_group("Mineral Types")
@export var spawn_jade: bool = true
@export var spawn_sapphire: bool = true
@export var spawn_ruby: bool = true
@export var spawn_iron: bool = true
@export var spawn_copper: bool = true

@export_group("Spawn Settings")
@export var spawn_position: Vector3 = Vector3.ZERO
@export var spacing: float = 1.5
@export var random_rotation: bool = true
@export var size_variation: float = 0.2

var spawned_minerals: Array = []

## TESTING METHOD
#func _input(event: InputEvent) -> void:
	#if Engine.is_editor_hint():
		#return
	#
	#if event is InputEventKey and event.pressed:
		#match event.keycode:
			#KEY_V:
				#var offset = 0.0
				#spawn_single("jade", Vector3(offset, 0, 0))
				#offset += spacing
				#spawn_single("sapphire", Vector3(offset, 0, 0))
				#offset += spacing
				#spawn_single("ruby", Vector3(offset, 0, 0))
				#offset += spacing
				#spawn_single("iron", Vector3(offset, 0, 0))
				#offset += spacing
				#spawn_single("copper", Vector3(offset, 0, 0))

# Clear all minerals
func clear_minerals() -> void:
	for mineral in spawned_minerals:
		if is_instance_valid(mineral):
			mineral.queue_free()
	spawned_minerals.clear()

# Spawn a single mineral at requested positon
# warning-ignore:shadowed_variable_base_class
func spawn_single(mineral_type: String, pos: Vector3) -> Node3D:
	var scene_path: String = ""
	
	match mineral_type.to_lower():
		"jade":
			scene_path = jade_scene
		"sapphire":
			scene_path = sapphire_scene
		"ruby":
			scene_path = ruby_scene
		"iron":
			scene_path = iron_scene
		"copper":
			scene_path = copper_scene
		_:
			push_error("Unknown mineral type: " + mineral_type)
			return null
	
	if scene_path == "":
		push_error("Scene path not set for mineral type: " + mineral_type)
		return null
	
	var packed_scene = load(scene_path)
	if not packed_scene:
		push_error("Failed to load mineral scene: " + scene_path)
		return null
	
	var mineral = packed_scene.instantiate()
	mineral.position = pos
	add_child(mineral)
	spawned_minerals.append(mineral)
	return mineral
