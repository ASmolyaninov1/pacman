extends Object
var tick_time: float = 0;
var position: Vector2 = Vector2.ZERO
var tilemap_layer: TileMapLayer = null
var current_direction: Vector2 = Vector2.ZERO
var next_direction: Vector2 = Vector2.ZERO
var target_position: Vector2 = Vector2.ZERO

func init(_position: Vector2, _tilemap_layer: TileMapLayer) -> void:
	position = _position
	tilemap_layer = _tilemap_layer
	target_position =_position
	position = snap_to_grid()
	target_position = position  # Изначально цель совпадает с позицией

func ticker(callback: Callable, delta: float, direction: Vector2, max_tick_time: int) -> void:
	if (tick_time > max_tick_time):
		tick_time = 0  # Сбрасываем таймер, если превыс
		next_direction = direction  # Обновляем направление
		position = get_new_position()
		callback.call(position, current_direction)
	if (tick_time >= 0):
		tick_time += delta * 1000
		return;

func set_position(new_position: Vector2) -> Vector2:
	position = new_position
	target_position = position  # Обновляем целевую позицию при установке новой позиции
	tick_time = 0  # Сбрасываем таймер при установке новой позиции
	position = snap_to_grid()
	return position

func get_new_position() -> Vector2:
	if is_at_cell_center() and can_move(next_direction):
		current_direction = next_direction
		# Если можем, обновляем целевую позицию
	update_target_position()
	position = position.move_toward(target_position, tilemap_layer.tile_set.tile_size.x * 3)
	
	# Привязываем к целевой позиции, если достигли её
	if position.distance_to(target_position) < 0.1:
		# position = target_position
		position = snap_to_grid()  # Убедимся, что позиция точная
	return position

func snap_to_grid() -> Vector2:
	var cell_pos = tilemap_layer.local_to_map(tilemap_layer.to_local(position))
	return tilemap_layer.to_global(tilemap_layer.map_to_local(cell_pos))

func is_at_cell_center() -> bool:
	var a = tilemap_layer.to_local(position)
	var cell_pos = tilemap_layer.local_to_map(a)
	var cell_center = tilemap_layer.map_to_local(cell_pos)
	return position.distance_to(tilemap_layer.to_global(cell_center)) < 0.5

func can_move(direction: Vector2) -> bool:
	if direction == Vector2.ZERO:
		return false
		
	# Получаем текущую клетку
	var current_cell = tilemap_layer.local_to_map(tilemap_layer.to_local(position))
	# Проверяем следующую клетку в направлении
	var next_cell = current_cell + Vector2i(direction)
		
	# Проверяем, есть ли стена в следующей клетке
	var tile_data = tilemap_layer.get_cell_tile_data(next_cell)
	if tile_data and tile_data.get_collision_polygons_count(0) > 0:
		
		return false  # Стена, нельзя двигаться
	return true

func update_target_position():
	if is_at_cell_center() and can_move(current_direction):
		var current_cell = tilemap_layer.local_to_map(tilemap_layer.to_local(position))
		var next_cell = current_cell + Vector2i(current_direction)
		target_position = tilemap_layer.to_global(tilemap_layer.map_to_local(next_cell))