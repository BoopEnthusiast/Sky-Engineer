extends Node3D

@onready var animation_player = $AnimationPlayer
@onready var page_container = $PageContainer
@onready var right_cover: AnimatableBody3D = $RightCover
@onready var left_cover: AnimatableBody3D = $"Left Cover"
@onready var turn_page_forward_button: InteractibleButton = $RightCover/TurnPageForwardButton
@onready var turn_page_backward_button: InteractibleButton = $"Left Cover/TurnPageBackwardButton"


var current_page_index = 0
var is_in_inventory = false
var is_open = true
var is_turning = false



func _ready() -> void:
	for i in range(page_container.get_child_count()):
		page_container.get_child(i).visible = (i == current_page_index)
	print("current page index ", current_page_index)
	right_cover.add_collision_exception_with(left_cover)
	left_cover.add_collision_exception_with(right_cover)
	set_book_state_from_inventory()


func _physics_process(_delta: float) -> void:
	look_at(Nodes.player.camera.global_position, Vector3.UP)
	basis = basis.rotated(basis.y.normalized(), PI/2)
	basis = basis.rotated(basis.z.normalized(), -PI/2)

func set_book_state_from_inventory():
	if is_in_inventory:
		close_book()
	else:
		open_book()
		
func open_book():
	animation_player.play("Open")
	page_container.visible = true
	await animation_player.animation_finished
	turn_page_forward_button.can_be_interacted_with = true
	turn_page_backward_button.can_be_interacted_with = true


func close_book():
	animation_player.play("Close")
	turn_page_forward_button.can_be_interacted_with = false
	turn_page_backward_button.can_be_interacted_with = false
	await animation_player.animation_finished
	page_container.visible = false 

func turn_page_forward():
	if is_open == true:
		if current_page_index < page_container.get_child_count() - 1:
			var animation_name = "Page_" + str(current_page_index) + "_Flip"
			animation_player.play(animation_name)
			page_container.get_child(current_page_index + 1).show()
			is_turning = true
			await animation_player.animation_finished
			if current_page_index >= 1:
				page_container.get_child(current_page_index - 1).hide()
			current_page_index += 1
			is_turning = false
			print("Turned page forward. Current page index: ", current_page_index)
		else:
			print("Already at the end of the book")


func turn_page_backward():
	if current_page_index > 0:
		var animation_name = "Page_" + str(current_page_index - 1) + "_Flip"
		animation_player.play_backwards(animation_name)
		#page_container.get_child(current_page_index).hide()
		page_container.get_child(current_page_index - 1).show()
		is_turning = true
		await animation_player.animation_finished
		page_container.get_child(current_page_index).hide()
		current_page_index -= 1
		is_turning = false

		print("Turned page backward. Current page index: ", current_page_index)
	else:
		print("Already at the beginning of the book")



func _on_turn_page_forward_button_button_pressed(_toggled: bool) -> void:
		if is_open == true: # Only allow page flipping if the book is open
			if current_page_index < page_container.get_child_count() - 1:
				if is_turning == false:
					turn_page_forward()

func _on_turn_page_backward_button_button_pressed(_toggled: bool) -> void:
		if is_open == true: # Only allow page flipping if the book is open
			if current_page_index >= 0:
				if is_turning == false:
					turn_page_backward()

func _on_grabbable_item_put_into_inventory() -> void:
	is_in_inventory = true
	close_book()
	print("Book is in inventory")


func _on_grabbable_item_taken_from_inventory() -> void:
	is_in_inventory = false
	open_book()
	print("Book is out of inventory")
