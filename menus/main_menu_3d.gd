class_name MainMenu
extends Node

signal play_game()
signal load_pressed()
@onready var camera: Camera3D
@onready var MainList: Node3D = $MainList

func _enter_tree():
	camera = get_node("MainMenu3D/MenuCamera")
	camera.visible = false
	
func _ready():
	MainList.visible = false
	camera.visible = true
	var tween = create_tween()
	tween.tween_callback(func(): MainList.visible = true).set_delay(0.0001)
	tween.tween_property(camera, "rotation_degrees:y", 0, 0.5) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)
		
func _on_play_pressed() -> void:
	%Audio/SelectSound.play()
	play_game.emit()

func _on_play_hovered() -> void:
	%Audio/HoverSound.play()

func _on_settings_hovered() -> void:
	%Audio/HoverSound.play()

func _on_quit_hovered() -> void:
	%Audio/HoverSound.play()
	
func _on_load_pressed():
	%Audio/SelectSound.play()
	var tween = create_tween()
	tween.tween_property(camera, "rotation_degrees:y", -90, 0.5) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)
	tween.connect("finished", Callable(self, "_emit_load_pressed"))

func _emit_load_pressed():
	load_pressed.emit()

func _on_load_hovered():
	%Audio/HoverSound.play()
