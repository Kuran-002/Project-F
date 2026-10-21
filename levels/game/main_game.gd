extends Node

const MAIN_MENU_SCENE = "res://levels/main_menu/main_menu.tscn"

const BOSS_DEATH: String = "boss_death"
const PLAYER_DEATH: String = "player_death"
const MUSIC_OVER: String = "music_over"

const PLAYER_WIN_TITLE: String = "[font_size=48][center]Victory![/center][/font_size]"
const PLAYER_LOSE_TITLE: String = "[font_size=48][center]Game Over![/center][/font_size]"
const PLAYER_WIN_MESSAGE: String = "[font_size=25][center]You Defeated the Boss![/center][/font_size]"
const PLAYER_DEATH_MESSAGE: String = "You Died!"
const MUSIC_OVER_MESSAGE: String = "The Music Ended!"

const VICTORY_COLOR: Color = Color(0.0, 1.0, 0.0, 0.169)
const LOSE_COLOR: Color = Color(1.0, 0.0, 0.0, 0.169)

@onready var player = $"Player"
@onready var boss = $"Enemy"

@export var result_canvas: CanvasLayer
@export var result_screen: ColorRect
@export var title_label: RichTextLabel
@export var subtitle_label: RichTextLabel
@export var play_again_button: Button
@export var main_menu_button: Button

@export var ammo_box_scene: PackedScene
const SPAWN_INTERVAL:float = 4.00	# Seconds between ammo box spawns
const MAX_BOXES = 8					# Boxes allowed on the map at once
const SPAWN_MARGIN:float = 3.00		# Keeps boxes away from the screen edge
const BOX_SIZE:float = 12.0			# Matches the ammo box collision shape
const SPAWN_RANGE_MIN:Vector2 = Vector2(80.0, 80.0)
const SPAWN_RANGE_MAX:Vector2 = Vector2(560.0, 280.0)
const ENEMY_CLEARANCE:float = 10.0	# Extra gap kept between boxes and the enemy
const SPAWN_ATTEMPTS = 20			# Random positions tried before skipping a spawn

var is_active: bool = true
var ammo_spawn_timer: Timer

signal on_game_start
signal on_game_end(reason: String)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.on_damage.connect(_on_player_damaged)
	player.on_death.connect(_on_player_death)
	boss.on_damage.connect(_on_enemy_damaged)
	boss.on_death.connect(_on_boss_death)
	boss.Music.finished.connect(_on_music_finished)
	play_again_button.pressed.connect(start_game)
	main_menu_button.pressed.connect(on_main_menu)
	ammo_spawn_timer = Timer.new()
	ammo_spawn_timer.wait_time = SPAWN_INTERVAL
	ammo_spawn_timer.autostart = true
	ammo_spawn_timer.timeout.connect(_spawn_ammo_box)
	add_child(ammo_spawn_timer)

func _spawn_ammo_box() -> void:
	if !is_active or get_tree().get_nodes_in_group("ammo_box").size() >= MAX_BOXES:
		return
	var shape = RectangleShape2D.new()
	shape.size = Vector2.ONE * (BOX_SIZE + ENEMY_CLEARANCE * 2.0)
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var space = get_viewport().world_2d.direct_space_state
	for attempt in SPAWN_ATTEMPTS:
		var pos = Vector2(
			randf_range(SPAWN_RANGE_MIN.x, SPAWN_RANGE_MAX.x),
			randf_range(SPAWN_RANGE_MIN.y, SPAWN_RANGE_MAX.y))
		query.transform = Transform2D(0.0, pos)
		var blocked = false
		for hit in space.intersect_shape(query):
			if hit.collider.is_in_group("enemy"):
				blocked = true
				break
		if !blocked:
			var box = ammo_box_scene.instantiate()
			box.position = pos
			add_child(box)
			return


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_player_damaged(amount: int, old_health: int, new_health: int) -> void:
	# TODO: Flash?
	# Could display damage numbers?
	pass	

func _on_enemy_damaged(amount: int, old_health: int, new_health: int) -> void:
	# TODO: Flash?
	# Could display damage numbers?
	pass
	
func create_result_screen_style(is_victory: bool) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	if is_victory:
		style.bg_color = VICTORY_COLOR
	else:
		style.bg_color = LOSE_COLOR
	return style
	
func on_play_again() -> void:
	print("Play Again")
	start_game()
	
func on_main_menu() -> void:
	print("Main Menu")
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)

func start_game() -> void:
	result_canvas.visible = false
	_clear_run_objects()
	is_active = true
	ammo_spawn_timer.start(SPAWN_INTERVAL)
	# TODO: START MUSIC
	on_game_start.emit()

func _clear_run_objects() -> void:
	for group in ["ammo_box", "bullet", "wave", "shell"]:
		for node in get_tree().get_nodes_in_group(group):
			node.queue_free()

func _on_player_death() -> void:
	# Display death screen
	print("Player Defeated")
	result_canvas.visible = true
	result_screen.color = LOSE_COLOR
	title_label.text = PLAYER_LOSE_TITLE
	subtitle_label.text = PLAYER_DEATH_MESSAGE
	on_game_end.emit(PLAYER_DEATH)
	# TODO: STOP MUSIC
	is_active = false
	
func _on_boss_death() -> void:
	# Display victory screen
	print("Boss Defeated")
	result_canvas.visible = true
	result_screen.color = VICTORY_COLOR
	title_label.text = PLAYER_WIN_TITLE
	subtitle_label.text = PLAYER_WIN_MESSAGE
	on_game_end.emit(BOSS_DEATH)
	# TODO: STOP MUSIC
	is_active = false

func _on_music_finished() -> void:
	if !is_active or boss.health <= 0:
		return
	result_canvas.visible = true
	result_screen.color = LOSE_COLOR
	title_label.text = PLAYER_LOSE_TITLE
	subtitle_label.text = MUSIC_OVER_MESSAGE
	is_active = false
	on_game_end.emit(MUSIC_OVER)
	
# TODO: End game when music is over
