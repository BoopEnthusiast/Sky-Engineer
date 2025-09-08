extends CraftArea

func _ready() -> void:
	if Engine.is_editor_hint():
		progress_bar_sprite.visible = display_progress_bar_sprite
	else:
		progress_bar_sprite.visible = false
	add_recipe_list(Recipes.INVENTORY)

func _on_node_entered(node: Node3D) -> void:
	nodes_inside.append(node)
	print("hi")
	_check_crafting_state()


func _update_if_should_craft() -> bool:
	# Get the available groups on all the nodes inside this craft area and the list of nodes that have them
	var available_groups: Dictionary[StringName, Array]
	for node: Node3D in nodes_inside:
		for node_group: StringName in node.get_groups():
			# Ignore internal groups (like those from the editor)
			if node_group.begins_with("_"):
				continue
			if available_groups.has(node_group):
				available_groups[node_group].append(node)
			else:
				available_groups[node_group] = [node]
	
	# For each list available to this craft area
	for recipe_list: Dictionary[Dictionary, PackedScene] in recipe_lists:
		# Get each recipe dictionary
		for recipe: Dictionary[StringName, int] in recipe_list:
			# Check if this recipe has all the requisite groups and enough items to make it
			var has_all_requirements := recipe.size() > 0
			var required_nodes: Array[Node3D]
			for key: StringName in recipe:
				if available_groups.has(key):
					if available_groups[key].size() >= recipe[key]:
						# Add only the required amount of nodes to the required nodes in case there's more than the required amount
						for i: int in range(recipe[key]):
							required_nodes.append(available_groups[key][i])
					else:
						has_all_requirements = false
						break
				else:
					has_all_requirements = false
					break
			# Found a matching recipe! Set private variables and return true
			if has_all_requirements:
				_nodes_used_to_craft = required_nodes
				_to_craft = recipe_list[recipe]
				return true
	return false
