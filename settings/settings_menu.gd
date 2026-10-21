extends Panel

@export var master_volume_slider: HSlider
@export var music_volume_slider: HSlider
@export var sfx_volume_slider: HSlider

@export var settings_button: Button
@export var save_button: Button
@export var close_button: Button

@export var default_save_button_text: String = "Save"
@export var default_save_text_color: Color = Color(1, 1, 1, 1)
@export var saved_button_text: String = "Saved!"
@export var saved_text_color: Color = Color(0, 1, 0, 1)
@export var save_cooldown: float = 0.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	master_volume_slider.value = Settings.get_volume(Settings.MASTER_VOLUME_KEY)
	music_volume_slider.value = Settings.get_volume(Settings.MUSIC_VOLUME_KEY)
	sfx_volume_slider.value = Settings.get_volume(Settings.SFX_VOLUME_KEY)
	
	settings_button.pressed.connect(_on_settings_opened)
	save_button.pressed.connect(_save_settings)
	close_button.pressed.connect(_close_settings)
	
	master_volume_slider.value_changed.connect(_on_master_slider_changed)
	music_volume_slider.value_changed.connect(_on_music_slider_changed)
	sfx_volume_slider.value_changed.connect(_on_sfx_slider_changed)

func _on_settings_opened() -> void:
	visible = true
	
var is_saving: bool = false
	
func _save_settings() -> void:
	if is_saving:
		print("Saving is on cooldown")
		return
	Settings.save_settings()
	save_button.text = saved_button_text
	save_button.add_theme_color_override("font_color", saved_text_color)
	is_saving = true
	print("Saving...")
	await get_tree().create_timer(save_cooldown).timeout
	print("Saved!")
	save_button.text = default_save_button_text
	save_button.add_theme_color_override("font_color", default_save_text_color)
	is_saving = false
	
func _close_settings() -> void:
	visible = false

func _on_master_slider_changed(value: float) -> void:
	Settings.set_volume(Settings.MASTER_VOLUME_KEY, value)
	
func _on_music_slider_changed(value: float) -> void:
	Settings.set_volume(Settings.MUSIC_VOLUME_KEY, value)

func _on_sfx_slider_changed(value: float) -> void:
	Settings.set_volume(Settings.SFX_VOLUME_KEY, value)
