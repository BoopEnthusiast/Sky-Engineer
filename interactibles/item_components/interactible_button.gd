@tool
class_name InteractibleButton
extends ItemShape
## Component scene meant to be added as a child of any items
##
## Add the item_shape.tscn scene as a child of any items the player should be able to interact with.
## Then, set the [member item_to_grab] to the relevant node of your scene that the player should move (usually the root node).


## Emitted when the button is clicked by the player.[br]
## [br]
## [param toggled] is toggled on and off each time it's pressed
signal button_pressed(toggled: bool)

## If this node is toggled on or not.
## The only affect this has is what [signal button_pressed] returns, which is the opposite of this and then this variable is flipped.
@export var toggled_on: bool = false


## Presses the button
func start_interacting_with() -> void:
	toggled_on = not toggled_on
	button_pressed.emit(toggled_on)
