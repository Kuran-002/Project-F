extends Area2D

const MAX_HEALTH:int = 500
var health:int = MAX_HEALTH
@onready var health_bar: ProgressBar = $"../HUD/EnemyHealth"
@export var Wave: PackedScene
@onready var Music:AudioStreamPlayer = $Music

signal beat

# Sprite names indexed by the 8 directions, starting at "right" going clockwise (screen y is down).
const DIRECTION_NAMES:Array[String] = [
	"right", "down_right", "down", "down_left", "left", "up_left", "up", "up_right"]

const BPM:float = 115.0
const SEC_IN_MIN:float = 60.0

var textures:Array[Texture2D] = []
var target:Node2D

# Boss Attack Variables
var rng = RandomNumberGenerator.new() 
var time:float = 0.0 
var beat_count:int = 0 
var action_count:int = 0
var timings = [0,1, 2, 5, 6]
var next_timing:int = timings[action_count] 
#var actions = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]

func start() -> void: 
	Music.play() 
	Music.seek(start_at * SEC_IN_MIN * BPM)

var loop_at:float  = 7  # in beats
var start_at:float = 0
var loop_action:int = 0

const OFFSET = 0.45

func beat_counter() -> void: 
	time = Music.get_playback_position() + AudioServer.get_time_since_last_mix()
	time -= AudioServer.get_output_latency()
	time += OFFSET
	var curr_beat:int = floor((time / SEC_IN_MIN) * BPM)
	# Emit signal if beat is updated
	if (curr_beat > beat_count): 
		beat_count = curr_beat
		beat.emit() 

func _on_beat() -> void: 
	#var next_action = actions[action_count] 
	if (beat_count >= next_timing): 
		if (action_count < timings.size()): 
			action_count += 1 
			if (action_count < timings.size()): 
				next_timing = timings[action_count]
			handle_action(1)
	
func handle_action(action:int) -> void: 
	match action: 
		1: 
			random_attack(PI/8)	
		2: 
			side_attack(PI/6)
		3: 
			sweep_attack(true)
		4: 
			sweep_attack(false)

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

	# Get accurate time in song
	beat_counter()

	# Loop for debugging
	if (beat_count > loop_at): 
		Music.seek(start_at * SEC_IN_MIN * BPM)
		beat_count = start_at
		action_count = loop_action 
		next_timing = timings[start_at]


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
	
	
