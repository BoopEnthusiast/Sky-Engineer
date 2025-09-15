extends Node3D

@export var sun: DirectionalLight3D
@export var moon: DirectionalLight3D
@export var world_env: WorldEnvironment
@export var star_sky:PackedScene
@export var star_count: int = 200
@export var sun_mesh: MeshInstance3D
@export var moon_mesh: MeshInstance3D
@export var spawn_area: Vector3 = Vector3(1000, 150, 1000)

@export var day_length: float = 120.0 # seconds for full 24h cycle
@export var sun_max_energy: float = 1.0
@export var moon_max_energy: float = 0.3
@export var day_sky_color: Color = Color(0.5, 0.7, 1.0)
@export var night_sky_color: Color = Color(0.02, 0.02, 0.05)

var time_of_day: float = 0.25 # 0.0 = midnight, 0.25 = sunrise, 0.5 = noon, 0.75 = sunset
var spawned_star: Array = []

func _ready():
	spawn_stars()


func _process(delta: float) -> void:
	# Advance time
	time_of_day = fmod(time_of_day + delta / day_length, 1.0)
	
	# Sun rotation (full circle in 24h)
	var sun_angle = time_of_day * 360.0
	sun.rotation_degrees.x = sun_angle - 90.0

	# Moon opposite the sun
	moon.rotation_degrees.x = sun_angle + 90.0

	# Control light intensities
	var sun_strength = clamp(cos(time_of_day * TAU) * 1.2, 0.0, 1.0)
	var moon_strength = clamp(cos((time_of_day + 0.5) * TAU) * 1.2, 0.0, 1.0)

	sun.light_energy = sun_max_energy * sun_strength
	moon.light_energy = moon_max_energy * moon_strength

	# Stars appear in at night
	if sun_strength < 0.2:
		toogle_visibility(true)
	else:
		toogle_visibility(false)

func spawn_stars():
	for i in range (star_count):
		var star_instance = star_sky.instantiate()
		var x = randf_range(-spawn_area.x/2, spawn_area.x/2)
		var z = randf_range(-spawn_area.z/2, spawn_area.z/2)
		star_instance.position = Vector3(x, spawn_area.y, z)
		add_child(star_instance)
		spawned_star.append(star_instance)

@warning_ignore("shadowed_variable_base_class")
func toogle_visibility(show: bool):
	for star_instance in spawned_star:
		if star_instance is MeshInstance3D:
			star_instance.visible = show
