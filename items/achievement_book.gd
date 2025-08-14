extends AnimatableBody3D

@onready var animation_player = $AnimationPlayer
@onready var page_container = $PageContainer


var current_page_index = 0
var is_in_inventory = false
var is_open = true


func _ready() -> void:
	for i in range(page_container.get_child_count()):
		page_container.get_child(i).visible = (i == 0)
	set_book_state_from_inventory() 

	
func set_book_state_from_inventory():
	if is_in_inventory:
		close_book()
	else:
		open_book()
		
func open_book():
	animation_player.play("Open")
	await animation_player.animation_finished
	page_container.visible = true

func close_book():
	animation_player.play("Close")
	await animation_player.animation_finished
	page_container.visible = false 

func _on_item_shape_being_put_into_inventory() -> void:
	is_in_inventory = true
	close_book()
	print("Book is in inventory")


func _on_item_shape_being_taken_from_inventory() -> void:
	is_in_inventory = false
	open_book()
	print("Book is out of inventory")

func turn_page_forward():
	if current_page_index < page_container.get_child_count() - 1:
		animation_player.play("Flip_forward")
		page_container.get_child(current_page_index + 1).hide() # Then hide the old page
		current_page_index += 1
		page_container.get_child(current_page_index).show() # And show the new page
		await animation_player.animation_finished
		print("Turned page forward. Current page index: ", current_page_index)
	else:
		print("Already at the end of the book")

func turn_page_backward():
	if current_page_index > 0:
		animation_player.play_backwards("Flip_forward")
		page_container.get_child(current_page_index - 1).hide()
		current_page_index -= 1
		page_container.get_child(current_page_index).show()
		await animation_player.animation_finished
		print("Turned page backward. Current page index: ", current_page_index)
	else:
		print("Already at the beginning of the book")


@warning_ignore("unused_parameter")
func _on_turn_page_forward_button_button_pressed(toggled: bool) -> void:
		if is_open: # Only allow page flipping if the book is open
			if current_page_index < page_container.get_child_count():
				turn_page_forward()


@warning_ignore("unused_parameter")
func _on_turn_page_backward_button_button_pressed(toggled: bool) -> void:
		if is_open: # Only allow page flipping if the book is open
			if current_page_index >= 0:
				turn_page_backward()
