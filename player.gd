extends Area2D 

#		y	-1			0			1
# x
# -1    up_left			left		down_left
# 0 	up				idle(right) down
# 1     up_right 		right 		down_right
const DIRECTIONS:Array[Array] = [
["up_left", "left", "down_left"],
["up", "right", "down"], 
["up_right", "right", "down_right"]] 

const MOVE_SPEED:float = 500.0		# Move speed of player (px/s) 
const DODGE_MULT:float = 2 		# Speed mult by dodge 

var screen_size:Vector2				# Bounds for player movement 
var health:int = 100				# Player health
var can_dodge:bool = true 			# Whether player can dodge 
var is_dodging:bool = false 		# Whether the player is dodging 
var velocity:Vector2 = Vector2.ZERO # Velocity vector of player 

# Places the player at a given starting position 
# pos -> starting position given as vector 
func start(pos:Vector2): 
	position = pos 
	show() 
	$CollisionShape2D.disabled = false 

# Keeps the player dodging for a certain amount of time 
func _on_dodge_timer_timeout() -> void: 
	is_dodging = false 
	$CollisionShape2D.disabled = false
	$DodgeInterval.start() 

# Resets can_dodge flag once interval has ended 
func _on_dodge_interval_timeout() -> void: 
	can_dodge = true 

func _ready() -> void: 
	screen_size = get_viewport_rect().size 
	start(Vector2(400, 400)) # TODO: REMOVE THIS 

func _process(delta: float) -> void: 
	# setting velocity vector (only if not dodging)
	if (!is_dodging): 
		velocity = Vector2.ZERO 
		if Input.is_action_pressed("move_up"): 
			velocity.y -= 1
		if Input.is_action_pressed("move_down"): 
			velocity.y += 1
		if Input.is_action_pressed("move_left"): 
			velocity.x -= 1
		if Input.is_action_pressed("move_right"): 
			velocity.x += 1
		# Adjust sprite based on direction moving 
		$AnimatedSprite2D.animation = DIRECTIONS[velocity.x + 1][velocity.y + 1]

	# normalize and adjust velocity 
	if (velocity.length() > 0): 
		velocity = velocity.normalized() * MOVE_SPEED
		$AnimatedSprite2D.play() 
	else: 
		$AnimatedSprite2D.stop() 

	# Dodges for a certain amount of time if able to 
	if Input.is_action_pressed("dodge"): 
		if (can_dodge):
			$DodgeTimer.start() 
			is_dodging = true 
			can_dodge = false 
			$CollisionShape2D.disabled = true 
			$AnimatedSprite2D.animation = "dodge_" + $AnimatedSprite2D.animation
	if(is_dodging): 
		velocity *= DODGE_MULT 

	# check player bounds 
	position += velocity * delta 
	position = position.clamp(Vector2.ZERO, screen_size) 
