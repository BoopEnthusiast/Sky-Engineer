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
var was_player_close = false
var is_opening = false


func _ready() -> void:
	for i in range(page_container.get_child_count()):
		page_container.get_child(i).visible = (i == current_page_index)
	right_cover.add_collision_exception_with(left_cover)
	left_cover.add_collision_exception_with(right_cover)
	set_book_state_from_inventory()


func _physics_process(_delta: float) -> void:
	var is_player_close = Nodes.player.global_position.distance_squared_to(global_position) < 13
	if is_player_close:
		look_at(Nodes.player.camera.global_position, Vector3.UP)
		basis = basis.rotated(basis.y.normalized(), PI/2)
		basis = basis.rotated(basis.z.normalized(), -PI/2)
	if not is_player_close and was_player_close:
		close_book()
	elif is_player_close and not was_player_close:
		open_book()
	was_player_close = is_player_close

func set_book_state_from_inventory():
	if is_in_inventory:
		close_book()
	else:
		open_book()
		
func open_book():
	if is_opening:
		await animation_player.animation_finished
	is_opening = true
	animation_player.play(&"Open")
	page_container.visible = true
	await animation_player.animation_finished
	is_opening = false
	turn_page_forward_button.can_be_interacted_with = true
	turn_page_backward_button.can_be_interacted_with = true

func close_book():
	if is_opening:
		await animation_player.animation_finished
	is_opening = true
	animation_player.play(&"Close")
	turn_page_forward_button.can_be_interacted_with = false
	turn_page_backward_button.can_be_interacted_with = false
	await animation_player.animation_finished
	is_opening = false
	page_container.visible = false 


func turn_page_forward():
	if is_open == true:
		if current_page_index < page_container.get_child_count() - 1:
			var animation_name = &"Page_" + str(current_page_index) + &"_Flip"
			animation_player.play(animation_name)
			is_turning = true
			await animation_player.animation_finished
			current_page_index += 1
			is_turning = false

func turn_page_backward():
	if current_page_index > 0:
		var animation_name = &"Page_" + str(current_page_index - 1) + &"_Flip"
		animation_player.play_backwards(animation_name)
		is_turning = true
		await animation_player.animation_finished
		current_page_index -= 1
		is_turning = false
		
func switch_page_visibility(index: int):
	var page = page_container.get_child(index)
	page.visible = not page.visible


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
	var tween = get_tree().create_tween()
	tween.tween_property(self, ^"scale", Vector3.ONE*0.35, 1)
	close_book()

func _on_grabbable_item_taken_from_inventory() -> void:
	is_in_inventory = false
	var tween = get_tree().create_tween()
	tween.tween_property(self, ^"scale", Vector3.ONE, 1)
	open_book()
