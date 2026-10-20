extends Area2D
@export var Bullet: PackedScene
@export var Shell: PackedScene

@onready var main_game: Node = get_parent().get_parent()

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
	$AnimatedSprite2D.animation_finished.connect(_on_animated_sprite_animation_finished)
	reload_timer = Timer.new()
	reload_timer.one_shot = true
	reload_timer.wait_time = RELOAD_TIME
	reload_timer.timeout.connect(_on_reload_finished)
	add_child(reload_timer)

func _on_animated_sprite_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "shoot":
		$AnimatedSprite2D.play("idle")

func add_reserve_ammo(amount: int) -> void:
	reserve_ammo += amount
	emit_ammo()

func is_reloading() -> bool:
	return !reload_timer.is_stopped()

func emit_ammo() -> void:
	ammo_changed.emit(curr_ammo, reserve_ammo, is_reloading())

func shoot() -> void: 
	$AnimatedSprite2D.animation = "idle" 
	curr_ammo -= 1
	emit_ammo()
	for i in range(3):
		var b = Bullet.instantiate()
		get_tree().current_scene.add_child(b) 
		b.global_transform = $Muzzle.global_transform 
		b.global_rotation_degrees += (i - 1) * 3
	$AnimatedSprite2D.play("shoot")
	$ShootSound.play()
	
func reload() -> void:
	eject_shells(MAX_AMMO - curr_ammo)
	$AnimatedSprite2D.play("reload")
	$ReloadSound.play()
	reload_timer.start()
	emit_ammo()

# Throws spent shells out of the side of the gun; they stay on the floor
func eject_shells(count: int) -> void:
	var side = Vector2(-global_transform.x.y, global_transform.x.x) * -sign(scale.y)
	for i in count:
		var shell = Shell.instantiate()
		get_tree().current_scene.add_child(shell)
		shell.launch(global_position, side)

# Moves shells from the reserve into the gun once the timer ends
func _on_reload_finished() -> void:
	$AnimatedSprite2D.play("idle")
	var moved = min(MAX_AMMO - curr_ammo, reserve_ammo)
	curr_ammo += moved
	reserve_ammo -= moved
	emit_ammo()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Game is not active. Don't shoot
	if !main_game.is_active:
		return
		
	# Attempts to shoot. Won't shoot if out of ammo
	if is_reloading():
		return
	if (Input.is_action_just_pressed("shoot") and curr_ammo > 0): 
		shoot() 
	if Input.is_action_just_pressed("reload") and curr_ammo < MAX_AMMO and reserve_ammo > 0:
		reload()
