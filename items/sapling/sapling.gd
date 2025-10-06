class_name Sapling
extends AnimatableBody3D

@onready var collider: CollisionShape3D = $Collider

@onready var mesh: TreeMesh = $Mesh

@onready var varient:ItemVarient =  $ItemVarient

@onready var grabber:GrabbableItem = $GrabbableItem


var starting_height = 1.0

var progress:float = 0

const GROWTH_PER_SEC:float = 1

var growing:bool = false

var limbs:Dictionary

var treeshape:Shoot

var painter


#These are just here for the sake of demonstration.
#they should be replaced with a variable dictating 
#the type of cauldron
@export var substance:StringName

func _ready():
	varient.substance = Substances.SUBSTANCES[substance]
	varient.primary_target = mesh.material_override
	varient.secondary_target = mesh.foliage.material_override
	
	#randomize()
	varient.paint()
	collider.shape = collider.shape.duplicate()
	treeshape = Shoot.new(0,0,8,8)
	mesh.set_instance_count(treeshape.get_instance_quantity())
	mesh.spawn_trunk()
	treeshape.height = starting_height
	limbs.set(0,treeshape)
	var objectshape = mesh.generate_collision_geometry()
	collider.shape = objectshape
	$GrabbableItem/Collider.shape = collider.shape
	var outlinemesh = MeshInstance3D.new()
	outlinemesh.mesh = objectshape
	var testarray:Array[MeshInstance3D] = [outlinemesh]
	$GrabbableItem.outline_when_interactible = testarray
	#plant()

func _process(delta):
	#I'm not putting the full grow function in here.
	#just calling it, and passing in delta allows
	#for greater flexability.
	if growing:
		grow(delta)

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
	mesh.set_instance_count(0)
	$GrabbableItem.can_be_interacted_with = true
	mesh.set_instance_count(treeshape.get_instance_quantity())
	mesh.spawn_trunk()
	limbs.set(0,treeshape)
	collider.shape = mesh.generate_collision_geometry()

func grow(time:float):
	# grows the tree by a certan amount each frame.
	# TODO figure out how to controll the branch structure, 
	#      improve collision detection.
	#      I'm thinking AStar might help with the former,
	#      not sure about performance, though.
	if growing:
		if limbs.size() == 0:
			growing = false
			collider.shape = mesh.generate_collision_geometry()
		progress += time
		var timegrowth = GROWTH_PER_SEC * time
		for index in limbs.keys():
			var limbshape = limbs.get(index)
			limbshape.height += timegrowth
			mesh.grow_limb(index,timegrowth)
			for branch in limbshape.branches.keys():
				if limbshape.height >= limbshape.branches.get(branch):
					var val = mesh.spawn_limb(index, 1, branch.direction,branch.angle,branch.width)
					branch.index = val
					limbs.set(val, branch)
					limbshape.branches.erase(branch)
			if(limbshape.height >= limbshape.max_height):
				limbs.erase(index)
		if(progress > 1):
			collider.shape = mesh.generate_collision_geometry()
			progress = 0
