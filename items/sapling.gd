class_name Sapling
extends AnimatableBody3D

@onready var starting_height = $Mesh.mesh.size.y

var progress:float = 0

const MAX_PROGRESS:int = 20

const GROWTH_PER_SEC:float = 1

var growing:bool = false

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
		
		$Mesh.mesh.size.y = starting_height + (GROWTH_PER_SEC * progress)
		$Mesh.position.y = (GROWTH_PER_SEC/2) * progress
		
		$Collider.shape.size.y = starting_height + (GROWTH_PER_SEC * progress)
		$Collider.position.y = (GROWTH_PER_SEC/2) * progress
		
	elif growing:
		growing = false
