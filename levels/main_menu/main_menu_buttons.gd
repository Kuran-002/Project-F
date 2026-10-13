extends Control

const GAME_SCENE = "res://main.tscn"

@export var play_button: Button
@export var settings_button: Button
@export var how_to_play_button: Button
@export var credits_button: Button
@export var close_credits_button: Button
@export var credits_panel: Panel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if play_button:
		play_button.pressed.connect(_on_play)
	if settings_button:
		settings_button.pressed.connect(_on_settings)
	if how_to_play_button:
		how_to_play_button.pressed.connect(_on_how_to_play)
	if credits_button:
		credits_button.pressed.connect(_on_credits)
	if close_credits_button:
		close_credits_button.pressed.connect(_on_close_credits)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_play() -> void:
	print("play pressed")
	get_tree().change_scene_to_file(GAME_SCENE)
	pass
	
func _on_settings() -> void:
	print("settings pressed")
	pass
	
func _on_how_to_play() -> void:
	print("how to play pressed")
	pass	
	
func _on_credits() -> void:
	print("toggle credits menu")
	credits_panel.visible = !credits_panel.visible
	pass
	
func _on_close_credits() -> void:
	print("close credits")
	credits_panel.visible = false
	pass
