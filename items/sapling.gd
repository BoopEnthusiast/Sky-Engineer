class_name Sapling
extends AnimatableBody3D

var progress:int = 0

const MAX_PROGRESS:int = 4

func plant():
	$ItemShape.can_be_grabbed = false
	$Timer.start()

func grow():
	if progress < MAX_PROGRESS:
		$Mesh.mesh.size.y += 1
		$Mesh.position.y += 0.5
		$Collider.shape.size.y += 1
		$Collider.position.y += 0.5
		progress += 1
	else:
		$Timer.stop()

func _on_timer_timeout() -> void:
	grow()
