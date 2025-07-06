class_name Debug2DLine
extends Resource
## A resource for [DebugCanvasItem] to know how to draw a polyline and to keep track of each line by instance of this resource.

var color: Color
var width: float = -1.0
var antialiased: bool = true


func _init(the_color: Color, the_width: float = -1.0, the_antialiased: bool = true) -> void:
	color = the_color
	width = the_width
	antialiased = the_antialiased
