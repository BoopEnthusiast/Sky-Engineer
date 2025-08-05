class_name Sapling
extends AnimatableBody3D

@onready var starting_height = 1.0

var progress:float = 0

const MAX_PROGRESS:int = 4

const GROWTH_PER_SEC:float = 1

var growing:bool = false

var branch = true

var number_of_limbs:int = 1

var number_of_sublimbs:int = 0

var limbs = [0]


func _ready():
	plant()
	pass

func _process(delta):
	if growing:
		grow_slow(delta)

func plant():
	$ItemShape.can_be_grabbed = false
	growing = true

func reset():
	progress = 0
	$Mesh.mesh.size.y = starting_height
	$Mesh.position.y = 0
	$Collider.shape.size.y = starting_height
	$Collider.position.y = 0

func grow_slow(time:float):
	if progress < MAX_PROGRESS and growing:
		progress += time
		
		var timegrowth = GROWTH_PER_SEC * time
		var growth = (GROWTH_PER_SEC * progress)
		var height = starting_height + growth
		
		if(limbs.size() < 3 and progress > 2):
			limbs.append($Mesh.spawn_limb(0,1,Vector3(0,0,1), 1,0.2))
			limbs.append($Mesh.spawn_limb(0,1, Vector3(1,0,0), 0.5,0.2))
			#limbs.remove_at(0)
		
		for index in limbs:
			$Mesh.grow_limb(index,timegrowth)

		
		
		$Collider.shape.size.y = starting_height + (GROWTH_PER_SEC * progress)
		$Collider.position.y = (GROWTH_PER_SEC/2) * progress
		
	elif growing:
		growing = false
