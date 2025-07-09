extends CharacterBody2D
const max_tick_time: int = 400

@export var speed: float = 16  # Скорость движения (пикселей/сек)
var screen_size: Vector2  # Размер игрового окна
var tilemap_layer: TileMapLayer  # Ссылка на слой TileMap
var target_position: Vector2  # Целевая позиция (центр следующей клетки)
var current_direction: Vector2 = Vector2.ZERO  # Текущее направление
var next_direction: Vector2 = Vector2.ZERO  # Запрошенное направление
var tick_time: int = 0

var discret_move = preload("res://discret_move.gd")

signal hit
signal eat
signal step_portal

func _ready():
	screen_size = get_viewport_rect().size
	# Находим уровень и TileMap
	var level = get_parent().get_node("Level")
	tilemap_layer = level.get_node("TileMapLayer") as TileMapLayer
	
	if not tilemap_layer:
		push_error("TileMapLayer (слой 0) не найден!")
		return
	
	# Устанавливаем начальную позицию в центре ближайшей клетки
	global_position = discret_move.snap_to_grid(global_position, tilemap_layer)
	target_position = global_position

func _physics_process(delta):
	
	# Получаем ввод для нового направления
	var input_direction = get_input_direction()
	play_animation()
	if input_direction != Vector2.ZERO:
		next_direction = input_direction

	if (tick_time > max_tick_time):
		tick_time = 0  # Сбрасываем таймер, если превыс
	if (tick_time > 0):
		tick_time += delta * 1000
		return;

	# Проверяем, можем ли сменить направление
	if is_at_cell_center() and can_move(next_direction):
		current_direction = next_direction
	
	# Обновляем целевую позицию
	update_target_position()

	
	# Двигаемся к целевой позиции
	global_position = global_position.move_toward(target_position, tilemap_layer.tile_set.tile_size.x * 3)
	check_tile_metadata(tilemap_layer.local_to_map(tilemap_layer.to_local(global_position)))
	
	# Привязываем к целевой позиции, если достигли её
	if global_position.distance_to(target_position) < 0.1:
		# global_position = target_position
		global_position = discret_move.snap_to_grid(global_position, tilemap_layer)  # Убедимся, что позиция точная
	
	tick_time += delta * 1000

func start(pos: Vector2):
	position = pos
	global_position = discret_move.snap_to_grid(global_position, tilemap_layer)  # Привязываем к сетке при старте
	show()
	$CollisionShape2D.disabled = false

func is_at_cell_center() -> bool:
	var a = tilemap_layer.to_local(global_position)
	var cell_pos = tilemap_layer.local_to_map(a)
	var cell_center = tilemap_layer.map_to_local(cell_pos)
	return global_position.distance_to(tilemap_layer.to_global(cell_center)) < 0.5

func can_move(direction: Vector2) -> bool:
	if direction == Vector2.ZERO:
		return false
	
	# Получаем текущую клетку
	var current_cell = tilemap_layer.local_to_map(tilemap_layer.to_local(global_position))
	# Проверяем следующую клетку в направлении
	var next_cell = current_cell + Vector2i(direction)
	
	# Проверяем, есть ли стена в следующей клетке
	var tile_data = tilemap_layer.get_cell_tile_data(next_cell)
	if tile_data and tile_data.get_collision_polygons_count(0) > 0:
		
		return false  # Стена, нельзя двигаться
	return true

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
			tilemap_layer.set_cell(cell)
		elif tile_data.get_custom_data('is_portal'):
			emit_signal('step_portal', cell)

func update_target_position():
	if is_at_cell_center() and can_move(current_direction):
		var current_cell = tilemap_layer.local_to_map(tilemap_layer.to_local(global_position))
		var next_cell = current_cell + Vector2i(current_direction)
		target_position = tilemap_layer.to_global(tilemap_layer.map_to_local(next_cell))

func play_animation():
	var dir = next_direction if current_direction == Vector2.ZERO else current_direction 
	if (dir == Vector2.RIGHT):
		$AnimatedSprite2D.play("pacman-right")
	elif (dir == Vector2.LEFT):
		$AnimatedSprite2D.play("pacman-left")
	elif (dir == Vector2.UP):
		$AnimatedSprite2D.play("pacman-up")
	elif (dir == Vector2.DOWN):
		$AnimatedSprite2D.play("pacman-down")
	else:
		$AnimatedSprite2D.stop()  # Останавливаем анимацию, если нет движения
