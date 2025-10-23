extends Node

@onready var world = get_parent()
@onready var save_ui = $CanvasLayer/Control
@onready var line_edit = $CanvasLayer/Control/LineEdit

var is_save_ui_open = false
var original_playing_state = false

# Initialize UI and load save if it exists
func _ready():
	save_ui.visible = false
	line_edit.text_submitted.connect(_on_save_name_submitted)
	if Save.has_pending_load():
		var pending_save_name = Save.get_pending_load()
		load_world_named(pending_save_name)

# Shows save pop up and pauses game
func show_save_ui():
	if is_save_ui_open:
		return
	is_save_ui_open = true
	save_ui.visible = true
	line_edit.text = ""
	line_edit.grab_focus()
	get_tree().paused = true

# Hides save popup and resumes game
func hide_save_ui():
	if not is_save_ui_open:
		return
	is_save_ui_open = false
	save_ui.visible = false
	line_edit.release_focus()
	get_tree().paused = false

# Inputs for save popup
func _input(event):
	if not PlayerState.is_playing_game:
		return
	
	if event.is_action_pressed("save") and not is_save_ui_open:
		show_save_ui()
		get_viewport().set_input_as_handled()
		
	if event.is_action_pressed("ui_cancel") and is_save_ui_open:
		hide_save_ui()
		get_viewport().set_input_as_handled()
	
	if event.is_action_pressed("quickSave") and Save.has_current_save():
		quick_update_save()

# Quick update current save without UI
func quick_update_save():
	if not Save.has_current_save():
		print("No current save to update")
		return
	
	if save_world_named(Save.get_current_save()):
		$Audio/SelectSound.play()
		print("Quick updated save: ", Save.get_current_save())
	else:
		print("Failed to quick update save: ", Save.get_current_save())

# Checks save is valid
func _on_save_name_submitted(save_name: String):
	if save_name.strip_edges().is_empty():
		print("Save name cannot be empty")
		return
	
	Save.set_current_save(save_name.strip_edges())
	
	if save_world_named(save_name):
		hide_save_ui()
	else:
		print("Save failed, try again")

# Packs and saves world to file
func save_world_named(save_name: String) -> bool:
	if save_name.is_empty():
		print("Error: Save name cannot be empty")
		return false
	
	var packed_scene = PackedScene.new()
	packed_scene.pack(world)
	var save_path = "user://save_%s.tscn" % save_name.strip_edges()
	var result = ResourceSaver.save(packed_scene, save_path)
	
	if result == OK:
		return true
	else:
		print("Failed to save world: ", save_name)
		return false

# Loads save file and swaps with current world
func load_world_named(save_name: String) -> bool:
	var path = "user://save_%s.tscn" % save_name.strip_edges()
	if not FileAccess.file_exists(path):
		print("No save found: ", save_name)
		return false
	
	var packed_scene = load(path)
	if packed_scene == null:
		print("Error: Failed to load save file")
		return false
		
	var new_world = packed_scene.instantiate()
	if new_world == null:
		print("Error: Failed to instantiate world")
		return false
	
	Save.set_current_save(save_name.strip_edges())
	
	var parent = world.get_parent()
	parent.add_child(new_world)
	world.queue_free()
	return true
