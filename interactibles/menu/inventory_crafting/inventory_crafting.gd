class_name InventoryCrafting
extends Node3D


const INVENTORY_CRAFTING_CORNER = preload("res://interactibles/menu/inventory_crafting/inventory_crafting_corner.tscn")

const LERP_SPEED = 10.0
const SIT_BELOW_INVENTORY_DISTANCE = 1.5

var corners: Array[InventoryCraftingCorner]

@onready var craft_area: CraftArea = $CraftArea


func _ready() -> void:
	for i: int in range(-1, 2, 2):
		for o: int in range(-1, 2, 2):
			for k: int in range(-1, 2, 2):
				print(i,"\t",o,"\t",k)
				var new_corner: InventoryCraftingCorner = INVENTORY_CRAFTING_CORNER.instantiate()
				add_child(new_corner)
				
				new_corner.position = Vector3(i, o, k) * 0.5 * craft_area.shape.size
				new_corner.rotation_degrees.x = max(o, 0) * 90
				new_corner.rotation_degrees.y = max(k, 0) * 90
				new_corner.rotation_degrees.z = max(i, 0) * 90
				if i > 0 and k > 0:
					new_corner.rotation_degrees.y = -90
				
				new_corner.position_changed.connect(_on_corner_position_changed)
				corners.append(new_corner)
				
				for mesh: MeshInstance3D in new_corner.meshes:
					mesh.mesh = mesh.mesh.duplicate(true)
					mesh.mesh.material.albedo_color = Color(float(i), float(o), float(k))


func reset_position() -> void:
	global_position = Nodes.menu.inventory_position + Vector3.DOWN * SIT_BELOW_INVENTORY_DISTANCE


func _on_corner_position_changed(corner: InventoryCraftingCorner) -> void:
	for corn: InventoryCraftingCorner in corners:
		if corn == corner:
			continue
		if corn.rotation.x == corner.rotation.x:
			corn.position.y = corner.position.y
		if corn.rotation.y == corner.rotation.y:
			corn.position.z = corner.position.z
		if corn.rotation.z == corner.rotation.z:
			corn.position.x = corner.position.x
