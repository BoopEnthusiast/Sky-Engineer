extends Node


## Dictionary, with the key of the StringName group name that are required in the recipes you can make in the inventory, and the value of how many of nodes with that group is required.[br]
## Then the preload of the item as the value of that initial dictionary. 
const INVENTORY: Dictionary[Dictionary, PackedScene] = { 
	{ &"Wood": 5, }: preload("res://items/workbench/wooden_workbench.tscn"),
}

## Same as [member INVENTORY].
const BASE_WORKBENCH: Dictionary[Dictionary, PackedScene] = {
	{ &"Wood": 7, }: preload("res://items/cauldron/cauldron.tscn"),
}
## Same as [member INVENTORY].
const WOODEN_WORKBENCH: Dictionary[Dictionary, PackedScene] = {
	{ &"Wood": 7, }: preload("res://items/cauldron/cauldron.tscn"),
}
const STONE_WORKBENCH: Dictionary[Dictionary, PackedScene] = {
	{ &"Wood": 7, }: preload("res://items/cauldron/cauldron.tscn"),
