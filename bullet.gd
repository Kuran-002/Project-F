extends Area2D

const SPEED:float = 700 		# Speed of the bullet 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Bullet goes straight forward
	position += transform.x * SPEED * delta 
	
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		area.call("take_damage", 10)
		queue_free()

func _on_body_entered(_body: Node2D) -> void:
	queue_free()
