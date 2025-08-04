extends AnimatableBody3D

@onready var animation_player = $AnimationPlayer



func _on_item_shape_being_put_into_inventory() -> void:
	animation_player.play("Close")


func _on_item_shape_being_taken_from_inventory() -> void:
	animation_player.play("Open")
