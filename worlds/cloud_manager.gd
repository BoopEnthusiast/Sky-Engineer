extends Node3D

@export var cloud_scene: PackedScene
@export var cloud_count: int = 20
@export var spawn_area: Vector3 = Vector3(400, 100, 400) # X,Z size of sky
@export var min_speed: float = 0.2
@export var max_speed: float = 0.8

func _ready() -> void:
	randomize()
	for i in range(cloud_count):
		var cloud = cloud_scene.instantiate()
		add_child(cloud)

		# Random spawn position within sky area
		var x = randf_range(-spawn_area.x/2, spawn_area.x/2)
		var y = randf_range(80, spawn_area.y) # keep them high
		var z = randf_range(-spawn_area.z/2, spawn_area.z/2)
		cloud.global_position = Vector3(x, y, z)

		# Random speed
		cloud.speed = randf_range(min_speed, max_speed)

		# Drift direction 
		cloud.direction = Vector3(1, 0, 0)
