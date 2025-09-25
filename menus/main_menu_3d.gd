class_name MainMenu
extends Node


signal play_game()


func _on_play_pressed() -> void:
	%Audio/SelectSound.play()
	play_game.emit()


func _on_play_hovered() -> void:
	%Audio/HoverSound.play()

func _on_settings_hovered() -> void:
	%Audio/HoverSound.play()

func _on_quit_hovered() -> void:
	%Audio/HoverSound.play()
