class_name BaseWorkbench
extends AnimatableBody3D


@onready var craft_area: CraftArea = $CraftArea


func _ready() -> void:
	craft_area.add_recipe_list(Recipes.BASE_WORKBENCH)
