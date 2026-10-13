extends Area2D
signal boss_hit

const SPEED:float = 1000.0 		# Speed of the bullet 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Bullet goes straight forward
	position += transform.x * SPEED * delta 
	
func _on_body_entered(body: Node2D) -> void:
	# sends out a signal if it hits the boss 
	if(body.is_in_group("boss")): 
		boss_hit.emit() 
	# bullet disappears after hitting something 
	queue_free() 
