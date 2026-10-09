extends CharacterBody2D
signal player_dead 					# Signal to be emmited when player dies

# Array of the names of the different direction animations 
const animations:Array = ["right", "up_right", "up", "up_left", 
						  "left", "down_left", "down", "down_right"]

@export var move_speed:int = 500	# Move speed of player (px/s) 
var screen_size:Vector2				# Bounds for player movement 
var health:int = 100				# Player health

# Places the player at a given starting position 
# pos -> starting position given as vector 
func start(pos:Vector2): 
	position = pos 
	show() 

func _ready() -> void: 
	screen_size = get_viewport_rect().size 
	start(Vector2(400, 400)) # TODO: REMOVE THIS 

func _process(delta: float) -> void: 
	# Movement Controls 
	# setting velocity vector 
	velocity = Vector2.ZERO 
	if Input.is_action_pressed("move_up"): 
		velocity.y -= 1
	if Input.is_action_pressed("move_down"): 
		velocity.y += 1
	if Input.is_action_pressed("move_left"): 
		velocity.x -= 1
	if Input.is_action_pressed("move_right"): 
		velocity.x += 1

	# normalize and adjust velocity 
	if (velocity.length() > 0): 
		velocity = velocity.normalized() * move_speed 
		$AnimatedSprite2D.play() 
	else: 
		$AnimatedSprite2D.stop() 

	# Adjust sprite based on direction moving 
	$AnimatedSprite2D.animation = animations[0]
	for i in range(1, 7): 
		if (velocity.angle() == i * PI / 4): 
			$AnimatedSprite2D.animation = animations[i] 
			break 

	# check player bounds 
	position += velocity * delta 
	position = position.clamp(Vector2.ZERO, screen_size) 

	
