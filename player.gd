extends CharacterBody2D

@export var move_speed:int = 1
var screen_size:Vector2

func _ready() -> void: 
	screen_size = get_viewport_rect().size 
	
func _process(delta: float) -> void:
	pass 
