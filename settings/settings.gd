extends Node

const SAVE_PATH = "user://settings.cfg"

const MASTER_VOLUME_KEY = "Master"
const MUSIC_VOLUME_KEY = "Music"
const SFX_VOLUME_KEY = "SFX"

var default_settings = {
	"Master": 1.0,
	"Music": 1.0,
	"SFX": 1.0
}

var settings = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_settings()
	
func get_volume(key: String) -> float:
	if settings.has(key):
		return settings[key]
	return 0.0

func set_volume(bus_name: String, value: float) -> void:
	var bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index == -1:
		return
	
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))

	if settings.has(bus_name):
		settings[bus_name] = value
	
func save_settings() -> void:
	var config = ConfigFile.new()
	for key in settings.keys():
		config.set_value("Audio", key, settings[key])
	var save_error = config.save(SAVE_PATH)
	if save_error == OK:
		print("Settings saved successfully to: ", SAVE_PATH)
	else:
		print("Sailed to save settings. Error code: ", save_error)
	
func load_settings() -> void:
	var config = ConfigFile.new()
	var error = config.load(SAVE_PATH)
	
	if error != OK:
		print("Settings file not found. Creating a new one")
		settings = default_settings.duplicate()
		save_settings()
		apply_audio_settings()
		return
	print("Settings file exists. Loading configurations")
	for key in default_settings.keys():
		settings[key] = config.get_value("Audio", key, default_settings[key])
		set_volume(key, settings[key])
	apply_audio_settings()
		
func apply_audio_settings() -> void:
	for key in settings.keys():
		var bus_index = AudioServer.get_bus_index(key)
		if bus_index != -1:
			AudioServer.set_bus_volume_db(bus_index, linear_to_db(settings[key]))
