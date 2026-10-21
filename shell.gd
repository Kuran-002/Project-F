extends Area2D

const FLIGHT_TIME:float = 0.6	# Seconds the shell is in the air
const ARC_HEIGHT:float = 30.0	# How high the shell pops up
const MIN_DISTANCE:float = 18.0	# Landing distance range from the gun
const MAX_DISTANCE:float = 38.0
const MIN_SPIN_TURNS = 2		# Full spins while flying (random between min and max)
const MAX_SPIN_TURNS = 4
const PUSH_SPEED:float = 120.0	# Speed given to a shell when the player steps on it
const FRICTION:float = 6.0		# How quickly a pushed shell slows down

@onready var body: Node2D = $Body
var landed:bool = false
var velocity:Vector2 = Vector2.ZERO

# Flings the shell from `from` towards `direction`, then leaves it on the floor
func launch(from: Vector2, direction: Vector2) -> void:
	global_position = from
	var spread = direction.rotated(randf_range(-0.5, 0.5))
	var landing = from + spread * randf_range(MIN_DISTANCE, MAX_DISTANCE)
	var move = create_tween()
	move.tween_property(self, "global_position", landing, FLIGHT_TIME)
	move.finished.connect(func(): landed = true)
	var hop = create_tween()
	hop.tween_property(body, "position:y", -ARC_HEIGHT, FLIGHT_TIME * 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	hop.tween_property(body, "position:y", 0.0, FLIGHT_TIME * 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	var spin = create_tween()
	var turns = randi_range(MIN_SPIN_TURNS, MAX_SPIN_TURNS) * (1.0 if randf() < 0.5 else -1.0)
	spin.tween_property(body, "rotation", turns * TAU + randf_range(0.0, TAU), FLIGHT_TIME)

func _physics_process(delta: float) -> void:
	if !landed:
		return
	for area in get_overlapping_areas():
		if area.is_in_group("player"):
			velocity = (global_position - area.global_position).normalized() * PUSH_SPEED
	if velocity.length_squared() > 1.0:
		global_position += velocity * delta
		body.rotation += velocity.x * delta * 0.1
		velocity = velocity.lerp(Vector2.ZERO, FRICTION * delta)
	else:
		velocity = Vector2.ZERO
