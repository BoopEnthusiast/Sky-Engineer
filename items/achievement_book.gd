extends AnimatableBody3D

@onready var animation_player = $AnimationPlayer
@onready var page_container = $PageContainer
@onready var page_flip_button_right = $RightCover/PageFlipButtonRight
@onready var page_flip_button_left = $"Left Cover/PageFlipButtonLeft"

var is_in_inventory = true
var is_open = true

func _ready() -> void:
	set_book_state_from_inventory() 
	
# Flipping pages 
	if page_flip_button_left:
		page_flip_button_left.input_event.connect(_on_page_flip_button_left_input_event)
	if page_flip_button_right:
		page_flip_button_right.input_event.connect(_on_page_flip_button_right_input_event)
	
func set_book_state_from_inventory():
	if is_in_inventory:
		close_book()
	else:
		open_book()
		
func open_book():
	animation_player.play("Open")
	page_container.visible = true

func close_book():
	animation_player.play("Close")
	page_container.visible = false 

func _on_item_shape_being_put_into_inventory() -> void:
	close_book()
	print("Book is in inventory")


func _on_item_shape_being_taken_from_inventory() -> void:
	open_book()
	print("Book is out of inventory")


func _on_page_flip_button_right_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if is_open: # Only allow page flipping if the book is open
			page_container.flip_page_backward()


func _on_page_flip_button_left_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if is_open: # Only allow page flipping if the book is open
			page_container.flip_page_forward()
