extends Area2D

const SPEED:float = 400 		# Speed of the bullet 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Bullet goes straight forward
	position += transform.x * SPEED * delta 
	
func _on_area_entered(area: Area2D) -> void:
	print("hit something")
	if area.is_in_group("player"):
		print("player_hit")
		area.call("take_damage", 250)
		queue_free()

func _on_body_entered(_body: Node2D) -> void:
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free() 
















	
