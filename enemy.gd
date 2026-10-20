extends Area2D

const MAX_HEALTH:int = 500
var health:int = MAX_HEALTH
@onready var health_bar: ProgressBar = $"../HUD/EnemyHealth"
var hit_flash_tween: Tween

var target:Node2D

func _ready() -> void:
	add_to_group("enemy")    
	health_bar.max_value = MAX_HEALTH
	health_bar.value = health

func _process(_delta: float) -> void:
	if target == null or !is_instance_valid(target):
		target = get_tree().get_first_node_in_group("player")
		if target == null:
			return
	var to_target:Vector2 = target.global_position - global_position
	# No back-facing sprite yet, so "front" is used whenever the player is above or below
	if abs(to_target.x) > abs(to_target.y):
		$AnimatedSprite2D.play("right" if to_target.x > 0.0 else "left")
	else:
		$AnimatedSprite2D.play("front")

func take_damage(amaount:int) -> void:
	health -= amaount
	health_bar.value = health
	if health <= 0:
		die()
	else:
		if hit_flash_tween and hit_flash_tween.is_running():
			hit_flash_tween.kill()
		$AnimatedSprite2D.modulate = Color.WHITE
		hit_flash_tween = create_tween()
		hit_flash_tween.tween_property($AnimatedSprite2D, "modulate", Color(1.4, 1.4, 1.4), 0.04)
		hit_flash_tween.tween_property($AnimatedSprite2D, "modulate", Color.WHITE, 0.12)
		
func die() -> void:
	queue_free()
	
	
