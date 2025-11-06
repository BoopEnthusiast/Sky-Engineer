extends Node3D

signal back_to_main

const HOVER_SCALE = 1.2
const LERP_SPEED = 8.0

var button_original_scales = {}

@onready var camera: Camera3D = $SaveMenu3D/SaveCamera
@onready var button_list: Node3D = $SettingsButtonList

@onready var master_handle = $MasterVolumeSlider/StaticBody/Handle
@onready var music_handle = $Music/StaticBody/Handle
@onready var sfx_handle = $SoundEffects/StaticBody/Handle
@onready var render_scale_handle = $RenderScale/StaticBody/Handle
@onready var fullscreen_button = $SettingsButtonList/Fullscreen
@onready var vsync_button = $SettingsButtonList/Vsync
@onready var set_fps_button = $SettingsButtonList/setFPS

var fullscreen_enabled: bool = false
var vsync_enabled: bool = true
var max_fps: int = 60
var render_scale: float = 100.0

# Hide the camera before scene is ready
func _enter_tree():
	if camera:
		camera.visible = false

# Animate camera rotation on scene open
func _ready():
	if button_list:
		button_list.visible = false
	
	if camera:
		camera.visible = true
		var tween = create_tween()
		tween.tween_callback(func(): 
			if button_list:
				button_list.visible = true
		).set_delay(0.001)
		tween.tween_property(camera, "rotation_degrees:y", 0, 0.5) \
			.set_trans(Tween.TRANS_SINE) \
			.set_ease(Tween.EASE_IN_OUT)
	
	connect_signals()
	load_settings()

# Connect handle signals for audio sliders
func connect_signals():
	if master_handle:
		master_handle.value_changed.connect(_on_master_volume_changed)
	
	if music_handle:
		music_handle.value_changed.connect(_on_music_volume_changed)
	
	if sfx_handle:
		sfx_handle.value_changed.connect(_on_sfx_volume_changed)
	
	if render_scale_handle:
		render_scale_handle.value_changed.connect(_on_render_scale_changed)

# Audio change handlers
func _on_master_volume_changed(value: float):
	if value <= 0:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
		var db = linear_to_db(value / 100.0)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db)

func _on_music_volume_changed(value: float):
	if value <= 0:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), true)
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), false)
		var db = linear_to_db(value / 100.0)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), db)

func _on_sfx_volume_changed(value: float):
	if value <= 0:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), true)
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), false)
		var db = linear_to_db(value / 100.0)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), db)

# Stores render scale value
func _on_render_scale_changed(value: float):
	render_scale = value
	apply_render_scale(render_scale)

# Applies render scale to viewport
func apply_render_scale(scale_value: float):
	var viewport = get_viewport()
	var normalized_scale = 0.1 + (scale_value / 100.0) * 0.9
	viewport.scaling_3d_scale = normalized_scale
	
	print("Applied render scale: ", normalized_scale)

# Back button handler
func _on_back_pressed():
	save_settings()
	if has_node("%Audio/SelectSound"):
		%Audio/SelectSound.play()
	
	if camera:
		var tween = create_tween()
		tween.tween_property(camera, "rotation_degrees:y", 110, 0.5) \
			.set_trans(Tween.TRANS_SINE) \
			.set_ease(Tween.EASE_IN_OUT)
		tween.connect("finished", Callable(self, "_emit_back_pressed"))
	else:
		_emit_back_pressed()

func _emit_back_pressed():
	back_to_main.emit()

# Save & Load settings
func save_settings():
	var config = ConfigFile.new()
	# Audio settings
	if master_handle:
		config.set_value("audio", "master_volume", master_handle.get_value())
	if music_handle:
		config.set_value("audio", "music_volume", music_handle.get_value())
	if sfx_handle:
		config.set_value("audio", "sfx_volume", sfx_handle.get_value())
	
	# Video settings
	config.set_value("video", "fullscreen", fullscreen_enabled)
	config.set_value("video", "vsync", vsync_enabled)
	config.set_value("video", "max_fps", max_fps)
	config.set_value("video", "render_scale", render_scale)
	
	config.save("user://settings.cfg")
	print("Settings saved!")

# 
func load_settings():
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	
	if err != OK:
		print("No settings file found, using defaults!")
		# Set defaults
		if master_handle:
			master_handle.set_value_no_signal(100)
			_on_master_volume_changed(100)
		if music_handle:
			music_handle.set_value_no_signal(80)
			_on_music_volume_changed(80)
		if sfx_handle:
			sfx_handle.set_value_no_signal(90)
			_on_sfx_volume_changed(90)
		
		# Apply default video settings
		fullscreen_enabled = false
		vsync_enabled = true
		max_fps = 60
		render_scale = 100.0
		apply_all_video_settings()
		update_button_text()
		return
	
	# Load saved audio values
	if master_handle:
		var vol = config.get_value("audio", "master_volume", 100)
		master_handle.set_value_no_signal(vol)
		_on_master_volume_changed(vol)
	
	if music_handle:
		var vol = config.get_value("audio", "music_volume", 80)
		music_handle.set_value_no_signal(vol)
		_on_music_volume_changed(vol)
	
	if sfx_handle:
		var vol = config.get_value("audio", "sfx_volume", 90)
		sfx_handle.set_value_no_signal(vol)
		_on_sfx_volume_changed(vol)
	
	# Load saved video settings
	fullscreen_enabled = config.get_value("video", "fullscreen", false)
	vsync_enabled = config.get_value("video", "vsync", true)
	max_fps = config.get_value("video", "max_fps", 60)
	render_scale = config.get_value("video", "render_scale", 100.0)
	
	# Apply all video settings
	apply_all_video_settings()
	update_button_text()
	
	# Apply render scale
	if render_scale_handle:
		render_scale_handle.set_value_no_signal(render_scale)
		_on_render_scale_changed(render_scale)
	
	print("Settings loaded!")

# Apply all video settings at once
func apply_all_video_settings():
	apply_fullscreen_setting(fullscreen_enabled)
	apply_vsync_setting(vsync_enabled)
	apply_render_scale(render_scale)


# Video button handlers
func _on_fullscreen_pressed():
	fullscreen_enabled = !fullscreen_enabled
	apply_fullscreen_setting(fullscreen_enabled)
	update_button_text()
	print("Fullscreen: ", fullscreen_enabled)


func _on_vsync_pressed():
	vsync_enabled = !vsync_enabled
	apply_vsync_setting(vsync_enabled)
	update_button_text()
	print("VSYNC: ", vsync_enabled)

# Cycles through the common fps options
func _on_set_fps_pressed():
	var fps_values = [30, 60, 120]
	var current_index = fps_values.find(max_fps)
	current_index = (current_index + 1) % fps_values.size()
	max_fps = fps_values[current_index]
	
	Engine.max_fps = max_fps
	
	update_button_text()
	print("MAX FPS: ", max_fps)

# Apply video settings to engine
func apply_fullscreen_setting(enabled: bool):
	if enabled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func apply_vsync_setting(enabled: bool):
	if enabled:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

# Update button text to reflect current state
func update_button_text():
	if fullscreen_button:
		fullscreen_button.text = "On" if fullscreen_enabled else "Off"
	
	if vsync_button:
		vsync_button.text = "On" if vsync_enabled else "Off"
	
	if set_fps_button:
		set_fps_button.text = str(max_fps)
