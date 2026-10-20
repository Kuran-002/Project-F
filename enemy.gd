extends Area2D

const MAX_HEALTH:int = 500
var health:int = MAX_HEALTH
@onready var health_bar: ProgressBar = $"../HUD/EnemyHealth"
@onready var rhythm: RhythmNotifier = $RhythmNotifier
@export var Wave: PackedScene

# Sprite names indexed by the 8 directions, starting at "right" going clockwise (screen y is down).
const DIRECTION_NAMES:Array[String] = [
	"right", "down_right", "down", "down_left", "left", "up_left", "up", "up_right"]

# Constants for music sync 
const LEAD_IN = 14 

var textures:Array[Texture2D] = []
var target:Node2D
var rng = RandomNumberGenerator.new() 

func start() -> void: 
	# Start music on start
	rhythm.audio_stream_player.play() 
	rhythm.beats(1).connect(func(i): print(i))

	rhythm.beats(1, true, 8).connect(func(i): 
		if (i % 8 < 3  
		): 
			random_attack(PI/6) 
	)

	rhythm.beats(0.5, true, 11).connect(func(i): 
		if (
			(i % (11 + 5) < 2 || (i % (11 + 5) >=3 && i % (11 + 5) <= 4))): 
			side_attack(PI/6)
	)

	rhythm.beats(1, true, 76).connect(func(i):
		if i < 3: 
			sweep_attack(true)
	)

func _ready() -> void:
	add_to_group("enemy")    
	health_bar.max_value = MAX_HEALTH
	health_bar.value = health
	start() 

	
	for name in DIRECTION_NAMES:
		textures.append(load("res://placeholders/%s.svg" % name))

func _process(_delta: float) -> void:
	if target == null or !is_instance_valid(target):
		target = get_tree().get_first_node_in_group("player")
		if target == null:
			return
	var angle:float = (target.global_position - global_position).angle()
	var index:int = posmod(roundi(angle / (PI / 4.0)), 8)
	$Sprite2D.texture = textures[index]
	# Throw attack in direction of angle
	$WeaponPivot.global_rotation = angle 


func take_damage(amaount:int) -> void:
	health -= amaount
	health_bar.value = health
	if health <= 0:
		die()

# Sweeping attack from left to right or right to left
func sweep_attack(clockwise:bool) -> void: 
	var angle:float = 0.0 
	var divisions:int = 10 
	var offset:float = (PI / divisions)
	divisions += 1 
	if (!clockwise): 
		angle = PI 
		offset = -offset
	for i in range(divisions): 
		attack(angle, false)	
		await get_tree().create_timer(0.2 / divisions).timeout
		angle += offset 

# Attack to the left and right of player by offset
func side_attack(offset:float) -> void: 
	attack(offset) 
	attack(-offset) 

# Attacks in randomized offset within angle set by cone 
func random_attack(angle:float) -> void: 
	var offset:float = rng.randf_range(-(angle/2), (angle/2))
	attack(offset) 
		
func attack(angle:float, is_offset:bool = true) -> void: 
	# TODO: Add attack animation?
	var b = Wave.instantiate()
	get_tree().current_scene.add_child(b) 
	b.global_transform = $WeaponPivot.global_transform
	if (is_offset): 
		b.global_rotation += angle  
	else: 
		b.global_rotation = angle 

func die() -> void:
	queue_free()
	
	
