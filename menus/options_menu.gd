extends Control

signal back_to_main

# Audio
@onready var master_volume_slider = $"Options Container/AudioContainer/MasterVolumeSlider"
@onready var music_volume_slider = $"Options Container/AudioContainer/HSlider"
@onready var sfx_volume_slider = $"Options Container/AudioContainer/HSlider2"

# Video
@onready var fullscreen_toggle = $"Options Container/VideoContainer/CheckButton"
@onready var vsync_toggle = $"Options Container/VideoContainer/CheckButton2"
# FPS options can be removed later if so desired cause they can mess with stuff
@onready var uncapped_fps_toggle = $"Options Container/VideoContainer/Uncapped FPS"
@onready var fps_spinbox = $"Options Container/VideoContainer/SpinBox"
@onready var fps_label = $"Options Container/VideoContainer/FPSLabel"
# Back
@onready var back_button = $"Back"

func _ready():
	# signals
	master_volume_slider.value_changed.connect(_on_master_volume_changed)
	music_volume_slider.value_changed.connect(_on_music_volume_changed)
	sfx_volume_slider.value_changed.connect(_on_sfx_volume_changed)
	
	fullscreen_toggle.toggled.connect(_on_fullscreen_toggled)
	vsync_toggle.toggled.connect(_on_vsync_toggled)
	uncapped_fps_toggle.toggled.connect(_on_uncapped_fps_toggled)
	fps_spinbox.value_changed.connect(_on_fps_changed)
	
	#back_button.pressed.connect(_on_back_pressed)
	
	setup_sliders()
	load_settings()

func setup_sliders():
	master_volume_slider.min_value = 0
	master_volume_slider.max_value = 100
	master_volume_slider.value = 100
	
	music_volume_slider.min_value = 0
	music_volume_slider.max_value = 100
	music_volume_slider.value = 80
	
	sfx_volume_slider.min_value = 0
	sfx_volume_slider.max_value = 100
	sfx_volume_slider.value = 90
	
	uncapped_fps_toggle.button_pressed = false

# Audio methods
func _on_master_volume_changed(value: float):
	print("Master Volume: ", value)
	var db = linear_to_db(value / 100.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db)
	
# when music and sfx added
func _on_music_volume_changed(value: float):
	print("Music Volume: ", value)
	var db = linear_to_db(value / 100.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), db)

func _on_sfx_volume_changed(value: float):
	print("SFX Volume: ", value)
	var db = linear_to_db(value / 100.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), db)

# Video methods
func _on_fullscreen_toggled(button_pressed: bool):
	print("Fullscreen: ", button_pressed)
	if button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_vsync_toggled(button_pressed: bool):
	print("VSYNC: ", button_pressed)
	if button_pressed:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

func _on_uncapped_fps_toggled(button_pressed: bool):
	print("UNCAPPED FPS: ", button_pressed)
	if button_pressed:
		Engine.max_fps = 0  # 0 = uncapped
		fps_spinbox.visible = false
		fps_label.visible = false
	else:
		Engine.max_fps = int(fps_spinbox.value)
		fps_spinbox.visible = true
		fps_label.visible = true

func _on_fps_changed(value: float):
	print("MAX FPS: ", value)
	if not uncapped_fps_toggle.button_pressed:
		Engine.max_fps = int(value)

# Back
func _on_back_pressed():
	save_settings()
	back_to_main.emit()

	
# Save & Load settings
func save_settings():
	var config = ConfigFile.new()
	
	# Audio
	config.set_value("audio", "master_volume", master_volume_slider.value)
	config.set_value("audio", "music_volume", music_volume_slider.value)
	config.set_value("audio", "sfx_volume", sfx_volume_slider.value)
	
	# Video
	config.set_value("video", "fullscreen", fullscreen_toggle.button_pressed)
	config.set_value("video", "vsync", vsync_toggle.button_pressed)
	config.set_value("video", "uncapped_fps", uncapped_fps_toggle.button_pressed)
	config.set_value("video", "max_fps", fps_spinbox.value)
	
	config.save("user://settings.cfg")
	print("Settings saved!!!!!!")

func load_settings():
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	
	if err != OK:
		print("No settings file found!!")
		return
	
	# Audio
	master_volume_slider.value = config.get_value("audio", "master_volume", 100)
	music_volume_slider.value = config.get_value("audio", "music_volume", 80)
	sfx_volume_slider.value = config.get_value("audio", "sfx_volume", 90)
	
	# Video
	fullscreen_toggle.button_pressed = config.get_value("video", "fullscreen", false)
	vsync_toggle.button_pressed = config.get_value("video", "vsync", true)
	uncapped_fps_toggle.button_pressed = config.get_value("video", "uncapped_fps", false)
	fps_spinbox.value = config.get_value("video", "max_fps", 60)
	
	print("Settings loaded!!")
	
	# Apply the settings
	_on_master_volume_changed(master_volume_slider.value)
	_on_music_volume_changed(music_volume_slider.value)
	_on_sfx_volume_changed(sfx_volume_slider.value)
	_on_fullscreen_toggled(fullscreen_toggle.button_pressed)
	_on_vsync_toggled(vsync_toggle.button_pressed)
	_on_uncapped_fps_toggled(uncapped_fps_toggle.button_pressed)
