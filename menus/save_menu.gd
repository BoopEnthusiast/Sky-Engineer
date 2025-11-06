extends Node3D
const HOVER_SCALE = 1.2
const LERP_SPEED = 8.0

var button_original_scales = {}
var is_editing_title: bool = false
var current_title_input: String = ""
var title_save_button

signal play_game()
signal back_pressed()

@onready var camera: Camera3D = $SaveMenu3D/SaveCamera
@onready var SaveButtonList: Node3D = $SaveButtonList

# Hide the camera before scene is ready for smooth transition
func _enter_tree():
	if camera:
		camera.visible = false

# Animate Camera rotation on scene open
func _ready():
	SaveButtonList.visible = false
	camera.visible = true
	var tween = create_tween()
	tween.tween_callback(func(): SaveButtonList.visible = true).set_delay(0.001)
	tween.tween_property(camera, "rotation_degrees:y", 0, 0.5) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)
	
	title_save_button = get_node_or_null("SaveButtonList/TitleSave")
	if title_save_button:
		title_save_button.text = "Enter save name to load."
	else:
		print("button not found")

# Keyboard input for save name
# warning-ignore:unused_parameter
func _unhandled_input(event):
	if not is_editing_title:
		return
		
	if event is InputEventKey and event.pressed:
		get_viewport().set_input_as_handled()
		match event.keycode:
			KEY_ENTER:
				finish_title_editing()
			KEY_BACKSPACE:
				if current_title_input.length() > 0:
					current_title_input = current_title_input.substr(0, current_title_input.length() - 1)
					update_title_display()
			KEY_ESCAPE:
				cancel_title_editing()
			_:
				if event.unicode >= 32 and event.unicode <= 126:
					current_title_input += char(event.unicode)
					update_title_display()

func _on_play_hovered() -> void:
	%Audio/HoverSound.play()

func _on_settings_hovered() -> void:
	%Audio/HoverSound.play()

func _on_quit_hovered() -> void:
	%Audio/HoverSound.play()

# Load the entered save name if it is not empty
func _on_load_selected_pressed():
	if not current_title_input.is_empty():
		load_game_with_name(current_title_input)
	else:
		print("No save name entered to load!")

# Checks the save name and loads it
func load_game_with_name(save_name: String):
	var save_path = "user://save_%s.tscn" % save_name.strip_edges()
	if not FileAccess.file_exists(save_path):
		print("Save file does not exist: ", save_name)
		if title_save_button:
			var original_text = current_title_input
			title_save_button.text = "Save not found!"
			await get_tree().create_timer(1.5).timeout
			current_title_input = original_text
			title_save_button.text = current_title_input + "|"
		return
	
	%Audio/SelectSound.play()
	Save.request_load(save_name)
	Save.set_current_save(save_name)
	play_game.emit()

# Starts text input mode
func _on_title_save_pressed():
	if not is_editing_title:
		start_title_editing()

# Enables editing
func start_title_editing():
	is_editing_title = true
	current_title_input = ""
	
	if title_save_button:
		title_save_button.text = "|"
		title_save_button.scale = Vector3(1.1, 1.1, 1.1)

# Updates button text when typing
func update_title_display():
	if title_save_button and is_editing_title:
		title_save_button.text = current_title_input + "|"
		title_save_button.scale = Vector3(1.1, 1.1, 1.1)

# Submits or exits text input mode 
func finish_title_editing():
	if not current_title_input.is_empty():
		load_game_with_name(current_title_input)
	else:
		is_editing_title = false
		if title_save_button:
			title_save_button.text = "Enter save name to load"

# Cancels text input mode and restores the button to default
func cancel_title_editing():
	is_editing_title = false
	current_title_input = ""
	if title_save_button:
		title_save_button.text = "Enter save name to load"

# Camera exit animation
func _on_back_pressed():
	%Audio/SelectSound.play()
	var tween = create_tween()
	tween.tween_property(camera, "rotation_degrees:y", -110, 0.5) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)
	tween.connect("finished", Callable(self, "_emit_back_pressed"))

func _emit_back_pressed():
	back_pressed.emit()
