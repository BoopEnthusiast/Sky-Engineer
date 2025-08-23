class_name Sapling
extends AnimatableBody3D

@onready var starting_height = 1.0

var progress:float = 0

@export var max_progress:int = 15

const GROWTH_PER_SEC:float = 1

var growing:bool = false

var branch = true

var number_of_limbs:int = 1000

var number_of_sublimbs:int = 0

var limbs:Dictionary

var treeshape:Shoot

func _ready():
	#randomize()
	treeshape = Shoot.new(0)
	$Mesh.set_instance_count(treeshape.get_instance_quantity())
	$Mesh.spawn_trunk()
	
	treeshape.height = starting_height
	limbs.set(0,treeshape)
	plant()
	pass

func _process(delta):
	#I'm not putting the full grow function in here.
	#just calling it, and passing in delta allows
	#for greater flexability.
	if growing:
		grow_slow(delta)

func plant():
	# Stops tree from being grabbed, and sets it growing
	# TODO integrate with vertex snapping, so the tree
	#      can be properly planted on surfaces.
	
	$GrabbableItem.can_be_interacted_with = false
	growing = true

# DEPRECATED
func reset():
	# This is intended to be used to break the tree back down
	# if the vertex it's on is destroyed. It doesn't work with
	# the current tree mesh.
	progress = 0
	$Mesh.multimesh.instance_count = 0
	$Mesh.multimesh.instance_count = 1 + number_of_limbs
	$GrabbableItem.can_be_interacted_with = true
	$Mesh.spawn_trunk()
	$Collider.shape.size.y = starting_height
	$Collider.position.y = 0

func grow_slow(time:float):
	# grows the tree by a certan amount each frame.
	# TODO figure out how to controll the branch structure, 
	#      improve collision detection.
	#      I'm thinking AStar might help with the former,
	#      not sure about performance, though.
	if growing:
		if limbs.size() == 0:
			growing = false
			#reset()
		
		progress += time
		
		var timegrowth = GROWTH_PER_SEC * time
		for index in limbs.keys():
			var limbshape = limbs.get(index)
			limbshape.height += timegrowth
			$Mesh.grow_limb(index,timegrowth)
			for branch in limbshape.branches.keys():
				if limbshape.height >= limbshape.branches.get(branch):
					var val = $Mesh.spawn_limb(index, 1, branch.direction,branch.angle,branch.width)
					branch.index = val
					limbs.set(val, branch)
					limbshape.branches.erase(branch)
				
			if(limbshape.height >= limbshape.max_height):
				limbs.erase(index)
		
		$Collider.shape.size = $Mesh.multimesh.get_aabb().size
		$Collider.position.y = (GROWTH_PER_SEC/2) * progress
		
	elif growing:
		growing = false
