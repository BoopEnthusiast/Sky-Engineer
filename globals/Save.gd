extends Node

var pending_load_name: String = ""
var current_save_name: String = ""

# Stores a save name to load after scene change
func request_load(save_name: String):
	pending_load_name = save_name

# Gets and clears the pending save name
func get_pending_load() -> String:
	var save_name = pending_load_name
	pending_load_name = ""
	return save_name

# Checks if a save is waiting to load
func has_pending_load() -> bool:
	return not pending_load_name.is_empty()

func clear_pending_load():
	pending_load_name = ""

func set_current_save(save_name: String):
	current_save_name = save_name

func get_current_save() -> String:
	return current_save_name

func has_current_save() -> bool:
	return not current_save_name.is_empty()
