extends CharacterBody2D
var max_tick_time: int = 400

var discret_move = preload("res://discret_move.gd").new()
var next_direction: Vector2 = Vector2.ZERO  # Направление движения
var tilemap_layer: TileMapLayer = null  # Ссылка на TileMapLayer
var road_tile_coords = Vector2i(37, 2)
var is_teleporting: bool = false

signal hit
signal eat
signal step_portal

func _ready():
	# Находим уровень и TileMap
	var level = get_parent().get_node("Level")
	tilemap_layer = level.get_node("TileMapLayer") as TileMapLayer
	
	if not tilemap_layer:
		push_error("TileMapLayer (слой 0) не найден!")
		return

	# Устанавливаем начальную позицию в центре ближайшей клетки
	discret_move.init(global_position, tilemap_layer)

func _physics_process(delta):
	
	# Получаем ввод для нового направления
	var input_direction = get_input_direction()
	if input_direction != Vector2.ZERO:
		next_direction = input_direction

	discret_move.ticker(func(new_position: Vector2, current_direction: Vector2) -> void:
		global_position = new_position
		play_animation(current_direction)
		check_tile_metadata(tilemap_layer.local_to_map(tilemap_layer.to_local(new_position)))
	, delta, next_direction, max_tick_time)

func start(pos: Vector2):
	global_position = discret_move.set_position(pos)
	show()
	$CollisionShape2D.disabled = false

func get_input_direction() -> Vector2:
	var direction = Vector2.ZERO
	if Input.is_action_pressed("right"):
		direction = Vector2.RIGHT
	elif Input.is_action_pressed("left"):
		direction = Vector2.LEFT
	elif Input.is_action_pressed("up"):
		direction = Vector2.UP
	elif Input.is_action_pressed("down"):
		direction = Vector2.DOWN
	return direction

func check_tile_metadata(cell: Vector2i):
	var tile_data = tilemap_layer.get_cell_tile_data(cell)
	if tile_data:
		if tile_data.get_custom_data('is_point'):
			emit_signal("eat", tile_data)
			# Удаляем точку и обновляем счет
			tilemap_layer.set_cell(cell, tilemap_layer.tile_set.get_source_id(0), road_tile_coords)
		elif tile_data.get_custom_data('is_portal'):
			if not is_teleporting:
				is_teleporting = true
				emit_signal('step_portal', cell)
				discret_move.update_global_position(global_position)
		else:
			is_teleporting = false  # Сбрасываем флаг, если не портал

func play_animation(direction: Vector2):
	if (direction == Vector2.RIGHT):
		$AnimatedSprite2D.play("pacman-right")
	elif (direction == Vector2.LEFT):
		$AnimatedSprite2D.play("pacman-left")
	elif (direction == Vector2.UP):
		$AnimatedSprite2D.play("pacman-up")
	elif (direction == Vector2.DOWN):
		$AnimatedSprite2D.play("pacman-down")
	else:
		$AnimatedSprite2D.stop()  # Останавливаем анимацию, если нет движения
