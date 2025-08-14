class_name Inventory3D
extends ProjectedMenuItem


const INVENTORY_SLOT = preload("res://interactibles/menu/inventory/inventory_slot.tscn")

var inventory_slots: Array[Array]


func _ready() -> void:
	for i: int in range(-2, 3):
		var new_inventory_slots: Array[InventorySlot]
		for o: int in range(-1, 2):
			var new_inventory_slot: Area3D = INVENTORY_SLOT.instantiate()
			add_child(new_inventory_slot)
			new_inventory_slot.position = Vector3(i, o, 0.1)
			new_inventory_slots.append(new_inventory_slot)
		inventory_slots.append(new_inventory_slots)
	super()


func _process(delta: float) -> void:
	if is_visible_in_tree():
		super(delta)
