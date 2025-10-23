class_name GameManager
extends Node

const MAIN_MENU = preload("res://menus/main_menu_3d.tscn")
const SAVE_MENU = preload("res://menus/save_menu.tscn")
const WORLD = preload("res://worlds/world.tscn")
const PLAYER = preload("res://interactibles/player.tscn")
const MENU = preload("res://interactibles/menu/menu.tscn")

@onready var main_menu: Node = $MainMenu
@onready var save_menu: Node = null

func _ready():
	var camera = main_menu.get_node("MainMenu3D/MenuCamera")
	if camera:
		camera.rotation_degrees.y = 0
		
func _on_main_menu_play_game() -> void:
	main_menu.queue_free()
	
	var world = WORLD.instantiate()
	add_child(world)
	
	var player = PLAYER.instantiate()
	add_child(player)
	player.global_position.y += 5
	# This removes a warning from looking at the camera right above 0, 0, 0 with projected menu items
	player.global_position.x += 0.001 
	
	var menu = MENU.instantiate()
	add_child(menu)
	
	PlayerState.is_playing_game = true

func _on_save_menu_play_game()-> void:
	save_menu.queue_free()
	
	var world = WORLD.instantiate()
	add_child(world)
	
	var player = PLAYER.instantiate()
	add_child(player)
	player.global_position.y += 5
	player.global_position.x += 0.001 
	
	var menu = MENU.instantiate()
	add_child(menu)
	
	PlayerState.is_playing_game = true
	
func _on_main_menu_load_pressed() -> void:
	main_menu.queue_free()
	save_menu = SAVE_MENU.instantiate()
	add_child(save_menu)
	
	save_menu.play_game.connect(_on_save_menu_play_game)
	save_menu.back_pressed.connect(_on_save_menu_back_pressed)


func _on_save_menu_back_pressed() -> void:
	save_menu.queue_free() 
	main_menu = MAIN_MENU.instantiate()
	add_child(main_menu)
	
	main_menu.play_game.connect(_on_main_menu_play_game)
	main_menu.load_pressed.connect(_on_main_menu_load_pressed)
