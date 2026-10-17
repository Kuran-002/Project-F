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

@export var result_screen: ColorRect
@export var title_label: RichTextLabel
@export var subtitle_label: RichTextLabel
@export var play_again_button: Button
@export var main_menu_button: Button

var is_active: bool = true

signal on_game_start
signal on_game_end(reason: String)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.on_damage.connect(_on_player_damaged)
	player.on_death.connect(_on_player_death)
	boss.on_damage.connect(_on_enemy_damaged)
	boss.on_death.connect(_on_boss_death)
	play_again_button.pressed.connect(start_game)
	main_menu_button.pressed.connect(on_main_menu)


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
	result_screen.visible = false
	is_active = true
	# TODO: START MUSIC
	on_game_start.emit()

func _on_player_death() -> void:
	# Display death screen
	print("Player Defeated")
	result_screen.visible = true
	result_screen.color = LOSE_COLOR
	title_label.text = PLAYER_LOSE_TITLE
	subtitle_label.text = PLAYER_DEATH_MESSAGE
	on_game_end.emit(PLAYER_DEATH)
	# TODO: STOP MUSIC
	is_active = false
	
func _on_boss_death() -> void:
	# Display victory screen
	print("Boss Defeated")
	result_screen.visible = true
	result_screen.color = VICTORY_COLOR
	title_label.text = PLAYER_WIN_TITLE
	subtitle_label.text = PLAYER_WIN_MESSAGE
	on_game_end.emit(BOSS_DEATH)
	# TODO: STOP MUSIC
	is_active = false
	
# TODO: End game when music is over
