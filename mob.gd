extends RigidBody2D
var ghosts = ["blinky"]
var max_tick_time: int = 400
var next_direction: Vector2 = Vector2.DOWN  # Направление движения
var tilemap_layer: TileMapLayer = null  # Ссылка на TileMapLayer

var discret_move = preload("res://discret_move.gd").new()
var player = null


func _ready():
	$AnimatedSprite2D.play(ghosts[randi() % ghosts.size()] + "-up")
	# Находим уровень и TileMap
	var level = get_parent().get_node("Level")
	tilemap_layer = level.get_node("TileMapLayer") as TileMapLayer
	
	if not tilemap_layer:
		push_error("TileMapLayer (слой 0) не найден!")
		return

	player = get_parent().get_node("Player") as CharacterBody2D
	if not player:
		push_error("Player не найден!")
		return

	# Устанавливаем начальную позицию в центре ближайшей клетки
	discret_move.init(global_position, tilemap_layer)

func _physics_process(delta):
	discret_move.ticker(func(new_position: Vector2, current_direction: Vector2) -> void:
		global_position = new_position
		play_animation(current_direction)
		next_direction = calculate_next_direction()
	, delta, next_direction, max_tick_time)

func calculate_next_direction() -> Vector2:
	var player_position = player.global_position as Vector2
	var mob_position = global_position

	var path = NavigationServer2D.map_get_path(
		get_world_2d().navigation_map,
		mob_position,
		player_position,
		false	
	)

	var d = (path[1] - mob_position).normalized()

	if (d == Vector2.RIGHT):
		print("RIGHT")
	elif (d == Vector2.LEFT):
		print("LEFT")
	elif (d == Vector2.UP):
		print("UP")
	elif (d == Vector2.DOWN):
		print("DOWN")
	return d
			

	

func play_animation(direction: Vector2) -> void:
	if direction == Vector2.RIGHT:
		$AnimatedSprite2D.play(ghosts[randi() % ghosts.size()] + "-right")
	elif direction == Vector2.LEFT:
		$AnimatedSprite2D.play(ghosts[randi() % ghosts.size()] + "-left")
	elif direction == Vector2.UP:
		$AnimatedSprite2D.play(ghosts[randi() % ghosts.size()] + "-up")
	elif direction == Vector2.DOWN:
		$AnimatedSprite2D.play(ghosts[randi() % ghosts.size()] + "-down")