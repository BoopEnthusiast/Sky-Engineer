class_name DebugCanvasItem
extends Node2D


var points_to_draw: Dictionary[Debug2DPoint, Vector2]
var lines_to_draw: Dictionary[Debug2DLine, PackedVector2Array]


func _draw() -> void:
	for point: Debug2DPoint in points_to_draw:
		draw_circle(points_to_draw[point], point.radius, point.color, point.filled, point.width, point.antialiased)
	for line: Debug2DLine in lines_to_draw:
		draw_polyline(lines_to_draw[line], line.color, line.width, line.antialiased)
