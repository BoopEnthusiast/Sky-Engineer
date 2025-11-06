extends Node3D

const HOVER_SCALE = 1.2
const LERP_SPEED = 8.0

var button_original_scales = {}

# Connect the hover signals for the children nodes
func _ready():
	for child in get_children():
		if child.has_signal("hovered") or child.has_method("_on_static_body_mouse_entered"):
			button_original_scales[child] = child.scale
			
			if child.has_signal("hovered"):
				child.connect("hovered", _on_button_hovered.bind(child))
			var static_body = child.get_node_or_null("StaticBody")
			if static_body:
				static_body.connect("mouse_entered", _on_button_hovered.bind(child))
				static_body.connect("mouse_exited", _on_button_unhovered.bind(child))

# animate button scale changes
func _process(_delta):
	for button in button_original_scales.keys():
		if is_instance_valid(button):
			var target_scale = button.get_meta("target_scale", button_original_scales[button])
			button.scale = button.scale.lerp(target_scale, LERP_SPEED * _delta)

# Scale up button on hover
func _on_button_hovered(button):
	if button_original_scales.has(button):
		button.set_meta("target_scale", button_original_scales[button] * HOVER_SCALE)
		%Audio/HoverSound.play()

# Reset buttons scale on exit
func _on_button_unhovered(button):
	if button_original_scales.has(button):
		button.set_meta("target_scale", button_original_scales[button])
