class_name Item
extends Resource


signal updated_polygon()

const EPSILON = 2.0

@export var icon: Texture2D:
	set(value):
		icon = value
		_create_mesh_from_icon()
var polygon: PackedVector2Array


func _create_mesh_from_icon() -> void:
	# A lot of this is taken from the internal Sprite2DEditor::_update_mesh_data method https://github.com/godotengine/godot/blob/4d1f26e1fd1fa46f2223fe0b6ac300744bf79b88/editor/scene/2d/sprite_2d_editor_plugin.cpp
	var image = icon.get_image()
	
	var rect: Rect2 = Rect2(Vector2(), image.get_size())
	
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(image)
	
	var lines: Array[PackedVector2Array] = bitmap.opaque_to_polygons(Rect2i(Vector2(), bitmap.get_size()), EPSILON)
	
	var outline_lines: Array[PackedVector2Array]
	outline_lines.resize(lines.size())
	for pi: int in range(lines.size()):
		var outline_line: PackedVector2Array
		outline_line.resize(lines[pi].size())
		 
		for i: int in range(lines[pi].size()):
			var vtx: Vector2 = lines[pi][i]
			outline_line[i] = vtx + rect.position
		
		outline_lines[pi] = outline_line
	
	# And the Sprite2DEditor::_convert_to_polygon_2d_node method 
	
	var total_point_count: int = 0
	for i: int in range(outline_lines.size()):
		total_point_count += outline_lines[i].size()
	
	polygon.resize(total_point_count)
	
	var uvs: PackedVector2Array
	uvs.resize(total_point_count)
	
	var current_point_index: int = 0
	
	var polys: Array
	polys.resize(outline_lines.size())
	
	for i: int in range(outline_lines.size()):
		var outline: PackedVector2Array = outline_lines[i]
		var uv_outline: PackedVector2Array = outline_lines[i]
		
		var pia: PackedInt32Array
		pia.resize(outline.size())
		
		for pi: int in range(outline.size()):
			polygon[current_point_index] = outline[pi]
			uvs[current_point_index] = uv_outline[pi]
			pia[pi] = current_point_index
			current_point_index += 1
		
		polys[i] = pia
	
	updated_polygon.emit()
