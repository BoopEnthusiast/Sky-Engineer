class_name Inventory
extends Node3D


var is_in_inventory := false

@onready var inventory_3d: Inventory3D = $Inventory3D
@onready var inventory_crafting: InventoryCrafting = $InventoryCrafting

func _ready() -> void:
	visible = false
	for i in range(0,inventory_3d.inventory_slots.size()):
		for o in range(0,inventory_3d.inventory_slots[i].size()):
			var coords = Vector2i(i,o)
			if StartingInventory.BASICLOADOUT.has(coords):
				var startitem = StartingInventory.BASICLOADOUT.get(coords).instantiate()
				Nodes.world.add_child(startitem)
				startitem.grabber.put_item_into_inventory(inventory_3d.inventory_slots[i][o])


func _process(_delta: float) -> void:
	# Open and close the inventory
	if Input.is_action_just_pressed(&"open_inventory"):
		is_in_inventory = not is_in_inventory
		visible = is_in_inventory
		if is_in_inventory:
			inventory_3d.move_to_remote_transform()
			inventory_crafting.reset_position()
