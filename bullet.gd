extends Area2D

const SPEED:float = 3000 		# Speed of the bullet 
var distance_travelled:float = 0.0
@onready var trail: Line2D = $Line2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Bullet goes straight forward
	var distance = SPEED * delta
	position += transform.x * distance
	distance_travelled += distance
	trail.set_point_position(0, Vector2(-distance_travelled, 0.0))
	if not get_viewport().get_visible_rect().grow(12.0).has_point(get_global_transform_with_canvas().origin):
		queue_free()
	
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		area.call("take_damage", 10)
		queue_free()

func _on_body_entered(_body: Node2D) -> void:
	queue_free()
