extends Node

@export var ammo_box_scene: PackedScene
const SPAWN_INTERVAL:float = 5.00	# Seconds between ammo box spawns
const MAX_BOXES = 5					# Boxes allowed on the map at once
const SPAWN_MARGIN:float = 3.00		# Keeps boxes away from the screen edge
const BOX_SIZE:float = 12.0			# Matches the ammo box collision shape
const ENEMY_CLEARANCE:float = 10.0	# Extra gap kept between boxes and the enemy
const SPAWN_ATTEMPTS = 20			# Random positions tried before skipping a spawn

func _ready() -> void:
	var timer = Timer.new()
	timer.wait_time = SPAWN_INTERVAL
	timer.autostart = true
	timer.timeout.connect(_spawn_ammo_box)
	add_child(timer)

func _spawn_ammo_box() -> void:
	if get_tree().get_nodes_in_group("ammo_box").size() >= MAX_BOXES:
		return
	var size = get_viewport().get_visible_rect().size
	var shape = RectangleShape2D.new()
	shape.size = Vector2.ONE * (BOX_SIZE + ENEMY_CLEARANCE * 2.0)
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var space = get_viewport().world_2d.direct_space_state
	for attempt in SPAWN_ATTEMPTS:
		var pos = Vector2(
			randf_range(SPAWN_MARGIN, size.x - SPAWN_MARGIN),
			randf_range(SPAWN_MARGIN, size.y - SPAWN_MARGIN))
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
