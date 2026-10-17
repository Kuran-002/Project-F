extends Area2D
@export var Bullet: PackedScene

@onready var main_game: Node = get_parent().get_parent()

const MAX_AMMO = 2				# Maximum amount of ammo
var curr_ammo = 0				# Current amount of ammo 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	curr_ammo = 1000 # TODO REMOVE THIS 
	$Muzzle.position = Vector2(10, -1)
	$AnimatedSprite2D.animation = "idle"

func shoot() -> void: 
	$AnimatedSprite2D.animation = "idle" 
	var b = Bullet.instantiate()
	var offset = -10 
	get_tree().current_scene.add_child(b) 
	b.global_transform = $Muzzle.global_transform 
	b.global_rotation_degrees += offset
	for i in range(4): 
		offset += 4 
		b = Bullet.instantiate()
		get_tree().current_scene.add_child(b) 
		b.global_transform = $Muzzle.global_transform 
		b.global_rotation_degrees += offset
	$AnimatedSprite2D.play("shoot")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Game is not active. Don't shoot
	if !main_game.is_active:
		return
		
	# Attempts to shoot. Won't shoot if out of ammo
	if (Input.is_action_just_pressed("shoot") and curr_ammo > 0): 
		shoot() 
