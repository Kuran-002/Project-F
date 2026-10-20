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
	sync() 

	# 4/4 -> Each Bar is 4 Beats
	# Bars 5-12 | 0:08 - 0:25
	# Bars 13-20 | 0:25 - 0:41 
	# Bars 21-28 | 0:41 - 0:58 
	# Bars 29-36 | 0:58 - 1:15 
	# Bars 37-44 | 1:15 - 1:31 
	# Bars 45-52 | 1:31 - 1:48 
	# Bars 53-60 | 1:48 - 2:04 

#	rhythm.beats(1, true, 76).connect(func(i):
#		if i < 3: 
#			sweep_attack(true)
#	)

var loop_at:float = 60 
var pos:float = 0 

# Attempts to sync actions to music 
func sync() -> void: 
	var cone = PI/10
	var r = rhythm
	r.audio_stream_player.seek(pos)
	# 4/4 -> Each Bar is 4 Beats
	# Bars 1-4 | 0:00 - 0:08
	r.beats(1, true, 7).connect(func(i): 
		if (i % 8 < 3 && r.current_position < 8): 
			attack(cone)) 
	# Bars 5-12 | 0:08 - 0:25
	r.beats(1, true, 15).connect(func(i): 
		if (i % 8 < 3 && r.current_position <= 23): 
			attack(cone)) 
	r.beats(0.5, true, 42).connect(func(i): 
		if (i < 2 || (i > 4 && i < 7)): 
			side_attack(PI/6))
	# Bars 13-20 | 0:25 - 0:41 
	r.beats(0.5, true, 49).connect(func(i): 
		if (i < 3 || (i > 5 && i < 8)): 
			side_attack(PI/6))
	r.beats(1, true, 54).connect(func(i): 
		if (i < 3): 
			attack(cone)) 
	r.beats(0.25, true, 61.5).connect(func(i): 
		if (i < 3 || (i > 9 && i < 13)
			|| (i > 24 && i < 32)): 
			side_attack(PI/6)) 
	r.beats(1, true, 72.5).connect(func(i): 
		if (i == 1): 
			sweep_attack(false)
		elif (i < 3): 
			sweep_attack(true))
	r.beats(0.5, true, 76).connect(func(i): 
		if (i < 4 && r.current_position <= 40): 
			random_attack(cone))
	# Bars 21-28 | 0:41 - 0:58 
	r.beats(0.25, true, 78).connect(func(i): 
		if (i < 3 || (i > 7 && i < 9) || (i > 12 && i < 15)): 
			side_attack(PI/8))
	r.beats(0.25, true, 84).connect(func(i):
		if (i < 5): 
			random_attack(cone))
	r.beats(0.25, true, 87).connect(func(i): 
		if (i < 5): 
			side_attack(PI/6))
	r.beats(0.25, true, 90).connect(func(i): 
		if (i < 5): 
			random_attack(cone))
	r.beats(0.25, true, 93).connect(func(i): 
		if (i < 5): 
			random_attack(cone))
	r.beats(0.5, true, 105).connect(func(i): 
		if (i < 2): 
			sweep_attack(true))
	# Bars 29-36 | 0:58 - 1:15 
	# Bars 37-44 | 1:15 - 1:31 
	# Bars 45-52 | 1:31 - 1:48 
	# Bars 53-60 | 1:48 - 2:04 

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
	if (rhythm.current_position > loop_at): 
		rhythm.audio_stream_player.seek(pos)


func take_damage(amaount:int) -> void:
	health -= amaount
	health_bar.value = health
	if health <= 0:
		die()

# Sweeping attack from left to right or right to left
func sweep_attack(clockwise:bool) -> void: 
	var angle:float = 0.0 
	var divisions:int = 5 
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
	
	
