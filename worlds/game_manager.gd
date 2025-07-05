class_name GameManager
extends Node


const WORLD = preload("res://worlds/world.tscn")
const PLAYER = preload("res://interactibles/player.tscn")
const INVENTORY = preload("res://interactibles/inventory/inventory.tscn")

@onready var main_menu: MainMenu = $Menu/MainMenu


func _on_main_menu_play_game() -> void:
	main_menu.visible = false
	
	var world = WORLD.instantiate()
	add_child(world)
	
	var player = PLAYER.instantiate()
	add_child(player)
	player.global_position.y += 5
	# This below removes a warning from looking at the camera right above 0, 0, 0 with projected inventory items
	player.global_position.x += 0.001 
	
	var inventory = INVENTORY.instantiate()
	add_child(inventory)
	inventory.inventory_3d.global_position.y += 5
	
	PlayerState.is_playing_game = true
