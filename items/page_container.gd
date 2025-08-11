extends Node3D

@onready var animation_player = $"../AnimationPlayer"
@onready var pages = get_children()

var current_page = 0
var total_pages = 0

func _ready() -> void:
	total_pages = pages.size()

func flip_page_forward():
	if current_page < 1:
		flip_page_1_forward()
	else:
		flip_page_2_forward()

func flip_page_backward():
	if current_page > 0:
		current_page 

func flip_page_1_forward():
	if current_page < total_pages:
		current_page += 1
		animation_player.play("Page_1_flip_forward")
		await animation_player.animation_finished
		print("Flipped to page 2")

func flip_page_2_forward():
	if current_page >= 1:
		current_page += 1
		animation_player.play("Page_2_flip_forward")
		await animation_player.animation_finished
		print("Flipped last page")
