class_name GameManager
extends Node


const MAIN = preload("res://worlds/main.tscn")
const PLAYER = preload("res://interactibles/player.tscn")
const SPINNY_CAMERA = preload("res://interactibles/spinny_camera.tscn")

@onready var main_menu: MainMenu = $Menu/MainMenu


func _on_main_menu_play_game() -> void:
	main_menu.visible = false
	print("setting up main")
	
	var main = MAIN.instantiate()
	add_child(main)
	
	print("setting up player")
	
	var player = PLAYER.instantiate()
	add_child(player)
	player.global_position.y += 5
	
	#var spinny_camera = SPINNY_CAMERA.instantiate()
	#add_child(spinny_camera)
