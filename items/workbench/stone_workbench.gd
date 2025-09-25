class_name StoneWorkbench
extends AnimatableBody3D


@onready var craft_area: CraftArea = $CraftArea


func _ready() -> void:
	craft_area.add_recipe_list(Recipes.STONE_WORKBENCH)
