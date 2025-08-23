class_name Shoot
extends Object

var branches:Dictionary[Shoot,float] = {}

@export var height:float = 1.0
@export var index:int = 0
var max_height:float = 4.0
var depth:int = 0
var probability:float = 1.0

var direction:Vector3 = Vector3(0,0,0)

var angle:float = 0.0

var thiccness:float = 1.0

var mast_point:float = max_height

var width:float = 1.0


func _init(depth:int, min_mast:float = 0, max_mast:float = 4, max_height:float = 4, dir:Vector3 = Vector3(0,0,0), ang:float = 0, wid:float = 1.0):
	
	var quantity:int = (randi() % 10) + 1 - (depth * 5)
	
	if depth > 0:
		mast_point = randf_range(min_mast, max_mast)
	
	direction = dir
	
	angle = ang
	
	width = wid
	
	var flots:Array[float] = [randf_range(-PI,PI)]
	
	for n in quantity:
		var h_angle = 0
		for angle in flots:
			h_angle -= angle
		h_angle = -h_angle
		flots.append(h_angle)
		var v_angle = randf_range(0.7,1.5)
		
		var fullrot = Quaternion.from_euler(Vector3(0,h_angle,v_angle)).normalized()
		#flots.append(part.inverse())
		
		var shoot = Shoot.new(depth + 1, 0, max_height, max_height/randf_range(0.25,0.75), fullrot.get_axis().normalized(), fullrot.get_angle(), 0.5)
		branches.set(shoot, shoot.mast_point)
	
	if depth > 0:
		pass
	
	
	var ten = 10
