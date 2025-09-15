extends Node3D

@export var cloud_scene: PackedScene
@export var cloud_count: int = 20
@export var spawn_area: Vector3 = Vector3(1000, 150, 1000) # X,Z = width/length, Y = height
@export var min_speed: float = 0.2
@export var max_speed: float = 0.8
@export var min_scale: float = 30
@export var max_scale: float = 50
@export var min_spacing: float = 30.0 # minimum distance between clouds

var cloud_positions: Array = []

func _ready() -> void:
	randomize()
	for i in range(cloud_count):
		var pos = get_valid_position()
		var cloud = cloud_scene.instantiate()
		add_child(cloud)

		# Place cloud
		cloud.global_position = pos

		# Random speed
		cloud.speed = randf_range(min_speed, max_speed)

		# Random scale
		var scale_value = randf_range(min_scale, max_scale)
		cloud.scale = Vector3(scale_value, 5, scale_value)

		# Save position for overlap check
		cloud_positions.append(pos)


func get_valid_position() -> Vector3:
	var attempts = 0
	while attempts < 50:
		var x = randf_range(-spawn_area.x/2, spawn_area.x/2)
		var y = randf_range(50, spawn_area.y) # keep them above ground
		var z = randf_range(-spawn_area.z/2, spawn_area.z/2)
		var candidate = Vector3(x, y, z)

		var valid = true
		for existing in cloud_positions:
			if candidate.distance_to(existing) < min_spacing:
				valid = false
				break

		if valid:
			return candidate
		attempts += 1

	# fallback if crowded
	return Vector3(randf_range(-spawn_area.x/2, spawn_area.x/2), 
				randf_range(50, spawn_area.y), 
				randf_range(-spawn_area.z/2, spawn_area.z/2)) 
