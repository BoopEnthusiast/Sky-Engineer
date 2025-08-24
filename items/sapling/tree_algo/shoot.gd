#This class creates the data structure the tree uses to decide which branch goes where.

class_name Shoot
extends Object

var branches:Dictionary[Shoot,float] = {}

@export var height:float = 1.0
@export var index:int = 0
var max_height:float = 4.0
var depth:int = 0

var direction:Vector3 = Vector3(0,0,0)

var angle:float = 0.0

var mast_point:float = max_height

var width:float = 1.0


func _init(tree_depth:int, tree_min_mast:float = 0, tree_max_mast:float = 4, tree_max_height:float = 4.0, dir:Vector3 = Vector3(0,0,0), ang:float = 0, wid:float = 1.0):
	# Constructor for a limb of the tree.
	depth = tree_depth
	max_height = tree_max_height
	
	var quantity:int = (randi() % 10) + 1 - (depth*3)
	
	if depth > 0:
		mast_point = randf_range(tree_min_mast, tree_max_mast)
	
	direction = dir
	
	angle = ang
	
	width = wid
	
	var flots:Array[float] = [randf_range(PI,2*PI)]
	
	for n in quantity:
		var h_angle = flots[0]
		for t_angle in flots:
			var threesixty = 2*PI
			var diff = fmod((h_angle - t_angle), threesixty)
			var dst = fmod(2*diff, threesixty) - diff
			h_angle = t_angle + (dst*randf_range(0.1,0.9))
		h_angle -= PI
		flots.append(h_angle)
		var v_angle = randf_range(0.7,1.5)
		
		var fullrot = Quaternion.from_euler(Vector3(0,h_angle,v_angle)).normalized()
		
		var shoot = Shoot.new(depth + 1, 0, max_height, max_height*randf_range(0.25,0.75), fullrot.get_axis().normalized(), fullrot.get_angle(), 0.5)
		branches.set(shoot, shoot.mast_point)
	
	if depth > 0:
		pass

func get_instance_quantity()->int:
	# Returns the number of limbs (including the trunk) the tree has.
	var count:int = 1
	
	for child in branches.keys():
		count += child.get_instance_quantity()
	return count
