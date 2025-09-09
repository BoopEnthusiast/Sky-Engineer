extends MeshInstance3D

@export var speed: float = 0.5
@export var direction: Vector3 = Vector3(1, 0, 0)

var start_position: Vector3

func _ready() -> void:
	start_position = global_position
	
func _process(delta: float) -> void:
	translate(direction * speed * delta)
	if global_position.x > 200:
		global_position.x = -200
