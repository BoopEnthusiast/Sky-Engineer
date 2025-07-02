class_name GameManager
extends Node


const MAIN = preload("res://worlds/main.tscn")
const PLAYER = preload("res://interactibles/player.tscn")
const SPINNY_CAMERA = preload("res://interactibles/spinny_camera.tscn")

@onready var main_menu: MainMenu = $Menu/MainMenu


func _on_main_menu_play_game() -> void:
	main_menu.visible = false
	
	var main = MAIN.instantiate()
	add_child(main)
	
	var player = PLAYER.instantiate()
	add_child(player)
	player.global_position.y += 5
	
	PlayerState.is_playing_game = true
