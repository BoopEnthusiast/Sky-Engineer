extends AnimatableBody3D

@onready var animation_player = $AnimationPlayer



func _on_item_shape_being_put_into_inventory() -> void:
	animation_player.play("Open")
