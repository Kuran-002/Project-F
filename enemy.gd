extends Area2D

const MAX_HEALTH:int = 500
var health:int = MAX_HEALTH
@onready var health_bar: ProgressBar = $"../HUD/EnemyHealth"
@onready var main_game: Node = get_parent()

signal on_damage(amount: int, old_health: int, new_health: int)
signal on_death

# Sprite names indexed by the 8 directions, starting at "right" going clockwise (screen y is down).
const DIRECTION_NAMES:Array[String] = [
	"right", "down_right", "down", "down_left", "left", "up_left", "up", "up_right"]

var textures:Array[Texture2D] = []
var target:Node2D

func _ready() -> void:
	add_to_group("enemy")    
	health_bar.max_value = MAX_HEALTH
	health_bar.value = health
	main_game.on_game_start.connect(on_game_start)
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

func take_damage(amount:int) -> void:
	if !main_game.is_active:
		return
	var old_health = health
	health = clamp(health - amount, 0, MAX_HEALTH)
	health_bar.value = health
	on_damage.emit(amount, old_health, health)
	if health <= 0:
		die()
		
func die() -> void:
	visible = false
	on_death.emit()
	
func reset_enemy() -> void:
	visible = true
	health = MAX_HEALTH
	health_bar.max_value = MAX_HEALTH
	health_bar.value = health
	
func on_game_start() -> void:
	reset_enemy()
	
	
