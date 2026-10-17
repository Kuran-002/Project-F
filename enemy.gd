extends Area2D

const MAX_HEALTH:int = 500
var health:int = MAX_HEALTH
@onready var health_bar: ProgressBar = $"../HUD/EnemyHealth"
@onready var rhythm: RhythmNotifier = $RhythmNotifier
@export var Wave: PackedScene

# Sprite names indexed by the 8 directions, starting at "right" going clockwise (screen y is down).
const DIRECTION_NAMES:Array[String] = [
	"right", "down_right", "down", "down_left", "left", "up_left", "up", "up_right"]

var textures:Array[Texture2D] = []
var target:Node2D

func start() -> void: 
	# Start music on start
	var rng = RandomNumberGenerator.new() 
	rhythm.audio_stream_player.play() 
	rhythm.beats(2).connect(func(i): attack(0)) 
	rhythm.beats(5).connect(func(i): attack(-0.2)) 
	rhythm.beats(7).connect(func(i): attack(-0.2)) 

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
		
func attack(offset:float) -> void: 
	# TODO: Add attack animation?
	var b = Wave.instantiate()
	get_tree().current_scene.add_child(b) 
	b.global_transform = $WeaponPivot.global_transform
	b.global_rotation += offset

func die() -> void:
	queue_free()
	
	
