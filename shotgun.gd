extends Area2D
@export var Bullet: PackedScene

const MAX_AMMO = 2				# Maximum amount of ammo

var curr_ammo = 0				# Current amount of ammo 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	curr_ammo = 1000 # TODO REMOVE THIS 

func shoot() -> void: 
	var b = Bullet.instantiate()
	get_tree().current_scene.add_child(b) 
	b.transform = $Muzzle.global_transform 
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Attempts to shoot. Won't shoot if out of ammo 
	if (Input.is_action_just_pressed("shoot")): 
		if (curr_ammo > 0): 
			shoot() 
		else: 
			pass
	# Shotgun stays w/ player 
	# Aims towards mouse 
