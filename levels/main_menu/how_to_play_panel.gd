extends Panel

@export var open_button: Button
@export var close_button: Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	open_button.pressed.connect(_on_open)
	close_button.pressed.connect(_on_close)
	
func _on_open() -> void:
	visible = true
	
func _on_close() -> void:
	visible = false
