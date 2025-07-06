extends Node
## A class full of useful functions for making visual representations of numbers to help debug.[br]
## The first instance of this being used was making 3 different lines to show the directions of a 3D
## node's basis, as an example of what you can do.


var _debug_label: Label
var _label_variables: Dictionary[StringName, String]
var _debug_canvas_item: DebugCanvasItem


func _ready() -> void:
	_debug_label = Label.new()
	add_child(_debug_label)
	
	var new_canvas_layer := CanvasLayer.new()
	new_canvas_layer.layer = 1000
	add_child(new_canvas_layer)
	_debug_canvas_item = DebugCanvasItem.new()
	new_canvas_layer.add_child(_debug_canvas_item)


## [i]Taken and modified from [url]https://youtu.be/JnrhURF1jgM[/url][/i][br]
## [br]
## Creates a [Debug3DLine] with [param points] and colored [param color], then returns it.
func create_3d_line(points: PackedVector3Array, color: Color = Color.WHITE) -> Debug3DLine:
	var debug_3d_line := Debug3DLine.new()
	
	debug_3d_line.my_mesh.surface_begin(Mesh.PRIMITIVE_LINES, debug_3d_line.my_material)
	for point: Vector3 in points:
		debug_3d_line.my_mesh.surface_add_vertex(point)
	debug_3d_line.my_mesh.surface_end()
	
	debug_3d_line.my_material.albedo_color = color
	
	add_child(debug_3d_line)
	
	return debug_3d_line


## Takes a [Debug3DLine] in (one from [method Debug.create_3d_line]) and changes its positions instead of creating a whole new mesh and stuff.[br]
## [br]
## If the new color is [constant Color.TRANSPARENT] then the color will not be updated.
func modify_3d_line(line: Debug3DLine, points: PackedVector3Array, color: Color = Color.TRANSPARENT) -> void:
	line.my_mesh.clear_surfaces()
	line.my_mesh.surface_begin(Mesh.PRIMITIVE_LINES, line.my_material)
	for point: Vector3 in points:
		line.my_mesh.surface_add_vertex(point)
	line.my_mesh.surface_end()
	
	if color != Color.TRANSPARENT:
		line.my_material.albedo_color = color


## [i]Taken and modified from [url]https://youtu.be/JnrhURF1jgM[/url][/i][br]
## [br]
## Creates a [Debug3DPoint] at [param position], with radius of [param radius] and colored [param color], then returns it.
func create_3d_point(position: Vector3, radius: float = 0.5, color: Color = Color.WHITE) -> Debug3DPoint:
	var debug_3d_point := Debug3DPoint.new()
	
	add_child(debug_3d_point)
	
	debug_3d_point.global_position = position
	
	debug_3d_point.my_mesh.radius = radius
	debug_3d_point.my_mesh.height = radius * 2
	
	debug_3d_point.my_material.albedo_color = color
	
	return debug_3d_point


## Takes a [Debug3DPoint] in (one from [method Debug.create_3d_point]) and changes its properties instead of creating a whole new mesh and stuff.[br]
## [br]
## If [param position] is [constant Vector3.INF] then the position will not be updated.[br]
## If [param radius] is less than 0 then the radius will not be updated.[br]
## If [param color] is [constant Color.TRANSPARENT] then the color will not be updated.
func modify_3d_point(point: Debug3DPoint, position: Vector3 = Vector3.INF, radius: float = -1.0, color: Color = Color.TRANSPARENT) -> void:
	if position != Vector3.INF:
		point.global_position = position
	
	if radius >= 0:
		point.my_mesh.radius = radius
		point.my_mesh.height = radius * 2
	
	if color != Color.TRANSPARENT:
		point.my_material.albedo_color = color


## Creates a [Debug2DLine] and begins drawing it everytime [method CanvasItem.queue_redraw] is called by using an internal [DebugCanvasItem].
func create_2d_line(points: PackedVector2Array, color: Color = Color.WHITE, width: float = -1.0, antialiased: bool = true) -> Debug2DLine:
	var debug_2d_line := Debug2DLine.new(color, width, antialiased)
	
	_debug_canvas_item.lines_to_draw[debug_2d_line] = points
	
	return debug_2d_line


## Takes a [Debug2DLine] in (one from [method Debug.create_2d_line]) and changes its properties.[br]
## [br]
## If [param points]'s only value is [constant Vector2.INF] then the points will not be updated.[br]
## If [param color] is [constant Color.TRANSPARENT] then the color will not be updated.[br]
## If [param width] is [constant INF] then the width will not be updated.
func modify_2d_line(line: Debug2DLine, points: PackedVector2Array = [Vector2.INF], color: Color = Color.TRANSPARENT, width: float = INF, antialiased: bool = true) -> void:
	if color != Color.TRANSPARENT:
		line.color = color
	
	if width != INF:
		line.width = width
	
	line.antialiased = antialiased
	
	if points.size() == 1:
		if points[0] == Vector2.INF:
			return
	_debug_canvas_item.lines_to_draw[line] = points


## Creates a [Debug2DPoint] and begins drawing it everytime [method CanvasItem.queue_redraw] is called by using an internal [DebugCanvasItem].
func create_2d_point(position: Vector2, color: Color = Color.WHITE, radius: float = 10.0, filled: bool = true, width: float = -1.0, antialiased: bool = true) -> Debug2DPoint:
	var debug_2d_point := Debug2DPoint.new(color, radius, filled, width, antialiased)
	
	_debug_canvas_item.points_to_draw[debug_2d_point] = position
	
	return debug_2d_point


## Takes a [Debug2DPoint] in (one from [method Debug.create_2d_point]) and changes its properties.[br]
## [br]
## If [param position] is [constant Vector2.INF] then the position will not be updated.[br]
## If [param color] is [constant Color.TRANSPARENT] then the color will not be updated.[br]
## If [param radius] is [constant INF] then the radius will not be updated.[br]
## If [param width] is [constant INF] then the width will not be updated.
func modify_2d_point(point: Debug2DPoint, position: Vector2 = Vector2.INF, color: Color = Color.TRANSPARENT, radius: float = INF, filled: bool = true, width: float = INF, antialiased: bool = true) -> void:
	if position != Vector2.INF:
		_debug_canvas_item.points_to_draw[point] = position
	
	if color != Color.TRANSPARENT:
		point.color = color
	
	if radius != INF:
		point.radius = radius
	
	point.filled = filled
	
	if width != INF:
		point.width = width
	
	point.antialiased = antialiased


## Prints [param value] in the top left. This works similar to Unreal where the [param key] means it won't print it on a second line.
func debug_print(key: StringName, value: Variant) -> void:
	_label_variables[key] = str(value)
	# Update the debug label each time it's written to
	_debug_label.text = ""
	for each_key: String in _label_variables:
		_debug_label.text += _label_variables[each_key] + '\n'


## Removes the debug print when you're done with it
func remove_debug_print(key: StringName) -> void:
	_label_variables.erase(key)
