extends Node3D

@onready var animation_player = $"../AnimationPlayer"
@onready var pages = get_children()

var current_page_index = 0
var total_pages = 0

func _ready():
	total_pages = pages.size()
	update_page_visibility()

func update_page_visibility():
	for i in range(total_pages):
		pages[i].visible = (i == current_page_index) # Only show the current page

func flip_page_forward():
	if current_page_index < total_pages - 1:
		current_page_index += 1
		animation_player.play("flip_page_forward") # Trigger page flip animation
		await animation_player.animation_finished # Wait for animation
		update_page_visibility()
		print("Flipped to page: ", current_page_index + 1)

func flip_page_backward():
	if current_page_index > 0:
		current_page_index -= 1
		animation_player.play("flip_page_backward") # Trigger page flip animation
		await animation_player.animation_finished # Wait for animation
		update_page_visibility()
		print("Flipped to page: ", current_page_index + 1)
