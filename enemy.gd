extends Area2D

const MAX_HEALTH:int = 500
var health:int = MAX_HEALTH
@onready var health_bar: ProgressBar = $"../HUD/EnemyHealth"
@export var Wave: PackedScene
@onready var Music:AudioStreamPlayer = $Music

signal beat
var hit_flash_tween: Tween
@onready var main_game: Node = get_parent()

signal on_damage(amount: int, old_health: int, new_health: int)
signal on_death

const BPM:float = 115.0
const SEC_IN_MIN:float = 60.0

var target:Node2D

# Boss Attack Variables
var rng = RandomNumberGenerator.new() 
var time:float = 0.0 
var beat_count:int = 0 
var action_count:int = 0
var timings = [8, 9, 10, 11, 12, 
				13, 14, 16, 17, 19,  
				20]
var actions = [1, 1, 1, 2, 2, 
				1, 2, 1, 1, 2, 
				2] 
var next_timing:int = timings[action_count] 
var next_action:int = actions[action_count]

const DEBUG:bool = true 
var loop_at:int  = 40  # in beats
var start_at:int = 20 
var loop_action:int = 11 

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
	if (beat_count == next_timing): 
		handle_action(next_action)
		action_count += 1
		if (action_count < actions.size()):
			next_action = actions[action_count]
			next_timing = timings[action_count]

	
func handle_action(action:int) -> void: 
	match action: 
		0: 
			pass
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
	main_game.on_game_start.connect(on_game_start)
	Music.play() 
	if (DEBUG):
		Music.seek((start_at / BPM) * SEC_IN_MIN)

func _process(_delta: float) -> void:
	if target == null or !is_instance_valid(target):
		target = get_tree().get_first_node_in_group("player")
		if target == null:
			return

	var angle:float = (target.global_position - global_position).angle()
	# Throw attack in direction of angle
	$WeaponPivot.global_rotation = angle 

	# Get accurate time in song
	beat_counter()

	#Loop for debugging
	if (beat_count > loop_at && DEBUG): 
		Music.seek((start_at / BPM) * SEC_IN_MIN)
		beat_count = start_at
		action_count = loop_action 
		next_timing = timings[start_at]

	var to_target:Vector2 = target.global_position - global_position
	# No back-facing sprite yet, so "front" is used whenever the player is above or below
	if abs(to_target.x) > abs(to_target.y):
		$AnimatedSprite2D.play("right" if to_target.x > 0.0 else "left")
	else:
		$AnimatedSprite2D.play("front")

func take_damage(amount:int) -> void:
	if !main_game.is_active:
		return
	var old_health = health
	health = clamp(health - amount, 0, MAX_HEALTH)
	health_bar.value = health
	on_damage.emit(amount, old_health, health)
	if health <= 0:
		die()
	else:
		if hit_flash_tween and hit_flash_tween.is_running():
			hit_flash_tween.kill()
		$AnimatedSprite2D.modulate = Color.WHITE
		hit_flash_tween = create_tween()
		hit_flash_tween.tween_property($AnimatedSprite2D, "modulate", Color(1.4, 1.4, 1.4), 0.04)
		hit_flash_tween.tween_property($AnimatedSprite2D, "modulate", Color.WHITE, 0.12)

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
	visible = false
	on_death.emit()
	
func reset_enemy() -> void:
	visible = true
	health = MAX_HEALTH
	health_bar.max_value = MAX_HEALTH
	health_bar.value = health

func reset_music() -> void: 
	Music.play()
	beat_count = 0
	action_count = 0
	next_timing = timings[action_count] 
	next_action = actions[action_count]
	
func on_game_start() -> void:
	reset_enemy()
	reset_music() 
	
	
