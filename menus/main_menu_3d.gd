class_name MainMenu
extends Node


signal play_game()


func _on_play_pressed() -> void:
	play_game.emit()
