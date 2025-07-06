class_name Debug2DPoint
extends Resource
## A resource for [DebugCanvasItem] to know how to draw a point and to keep track of each point by instance of this resource.

var color: Color
var radius: float
var filled: bool = true
var width: float = -1.0
var antialiased: bool = true


func _init(the_color: Color, the_radius: float, the_filled: bool = true, the_width: float = -1.0, the_antialiased: bool = true) -> void:
	color = the_color
	radius = the_radius
	filled = the_filled
	width = the_width
	antialiased = the_antialiased
