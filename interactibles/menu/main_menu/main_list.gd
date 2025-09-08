extends Node3D

func _on_settings_pressed() -> void:
	var options_scene = preload("res://menus/options_menu.tscn")
	var options_instance = options_scene.instantiate()
	
	# Connect the back signal in options
	options_instance.back_to_main.connect(_on_back_from_options)
	
	get_tree().current_scene.add_child(options_instance)
	# Hide menu scene
	hide()
	
# Bring back menu
func _on_back_from_options():
	show()
	var options_node = get_tree().current_scene.get_node("OptionsMenu")
	if options_node:
		options_node.queue_free()

func _on_quit_pressed() -> void:
	get_tree().quit()
