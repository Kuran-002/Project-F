extends Area2D
@export var Bullet: PackedScene

signal ammo_changed(current: int, reserve: int, reloading: bool)
const MAX_AMMO = 2				# Shells the gun holds
const RELOAD_TIME:float = 1.5	# Seconds a reload takes
const START_RESERVE = 6			# Spare shells at the start
var curr_ammo = MAX_AMMO		# Shells currently loaded
var reserve_ammo = START_RESERVE	# Spare shells; reloading draws from here
var reload_timer:Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Muzzle.position = Vector2(10, -1)
	$AnimatedSprite2D.animation = "idle"
	reload_timer = Timer.new()
	reload_timer.one_shot = true
	reload_timer.wait_time = RELOAD_TIME
	reload_timer.timeout.connect(_on_reload_finished)
	add_child(reload_timer)

func is_reloading() -> bool:
	return !reload_timer.is_stopped()

func emit_ammo() -> void:
	ammo_changed.emit(curr_ammo, reserve_ammo, is_reloading())

func shoot() -> void: 
	$AnimatedSprite2D.animation = "idle" 
	var b = Bullet.instantiate()
	var offset = -10 
	curr_ammo -= 1
	emit_ammo()
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
	
func reload() -> void:
	$AnimatedSprite2D.play("reload")
	reload_timer.start()
	emit_ammo()

# Moves shells from the reserve into the gun once the timer ends
func _on_reload_finished() -> void:
	$AnimatedSprite2D.play("idle")
	var moved = min(MAX_AMMO - curr_ammo, reserve_ammo)
	curr_ammo += moved
	reserve_ammo -= moved
	emit_ammo()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_reloading():
		return
	# Attempts to shoot. Won't shoot if out of ammo 
	if (Input.is_action_just_pressed("shoot") and curr_ammo > 0): 
		shoot() 
	if Input.is_action_just_pressed("reload") and curr_ammo < MAX_AMMO and reserve_ammo > 0:
		reload()
