class_name Sapling
extends AnimatableBody3D

@onready var starting_height = 1.0

var progress:float = 0

@export var max_progress:int = 4

const GROWTH_PER_SEC:float = 1

var growing:bool = false

var branch = true

var number_of_limbs:int = 2

var number_of_sublimbs:int = 0

var limbs = [0]

func _ready():
	#plant()
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
	
	$ItemShape.can_be_grabbed = false
	growing = true

# DEPRECATED
func reset():
	# This is intended to be used to break the tree back down
	# if the vertex it's on is destroyed. It doesn't work with
	# the current tree mesh.
	progress = 0
	$Mesh.mesh.size.y = starting_height
	$Mesh.position.y = 0
	$Collider.shape.size.y = starting_height
	$Collider.position.y = 0

func grow_slow(time:float):
	# grows the tree by a certan amount each frame.
	# TODO randomize branch placement, improve collision detection.
	if progress < max_progress and growing:
		progress += time
		
		var timegrowth = GROWTH_PER_SEC * time
		
		if(limbs.size() < number_of_limbs + 1 and progress > 2):
			limbs.append($Mesh.spawn_limb(0,1,Vector3(0,0,1), 1,0.2))
			limbs.append($Mesh.spawn_limb(0,1, Vector3(1,0,0), 0.5,0.2))
			#limbs.remove_at(0)
		
		for index in limbs:
			$Mesh.grow_limb(index,timegrowth)
		
		$Collider.shape.size.y = starting_height + (GROWTH_PER_SEC * progress)
		$Collider.position.y = (GROWTH_PER_SEC/2) * progress
		
	elif growing:
		growing = false
