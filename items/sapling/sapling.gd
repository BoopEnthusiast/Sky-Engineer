class_name Sapling
extends AnimatableBody3D

@onready var starting_height = 1.0

var progress:float = 0

const GROWTH_PER_SEC:float = 1

var growing:bool = false

var limbs:Dictionary

var treeshape:Shoot

func _ready():
	#randomize()
	treeshape = Shoot.new(0,0,8,8)
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

func reset():
	# This is intended to be used to break the tree back down
	# if the vertex it's on is destroyed.
	growing = false
	progress = 0
	$Mesh.set_instance_count(0)
	$Mesh.set_instance_count(treeshape.get_instance_quantity())
	$GrabbableItem.can_be_interacted_with = true
	$Mesh.spawn_trunk()
	$Collider.shape = $Mesh.generate_collision_geometry()

func grow_slow(time:float):
	# grows the tree by a certan amount each frame.
	# TODO figure out how to controll the branch structure, 
	#      improve collision detection.
	#      I'm thinking AStar might help with the former,
	#      not sure about performance, though.
	if growing:
		if limbs.size() == 0:
			growing = false
			$Collider.shape = $Mesh.generate_collision_geometry()
		
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
		
		#$Collider.make_convex_from_siblings()
		#$Collider.position.y = (GROWTH_PER_SEC/2) * progress
		if(progress > 1):
			$Collider.shape = $Mesh.generate_collision_geometry()
			progress = 0
		
	elif growing:
		growing = false
