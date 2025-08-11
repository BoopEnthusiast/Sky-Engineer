@tool
class_name InteractibleButton
extends ItemShape
## Component scene meant to be added as a child of any items
##
## Add the item_shape.tscn scene as a child of any items the player should be able to interact with.
## Then, set the [member item_to_grab] to the relevant node of your scene that the player should move (usually the root node).


## Emitted when the button is clicked by the player
