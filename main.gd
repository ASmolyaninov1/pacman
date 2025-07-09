extends Node

@export var mob_scene: PackedScene
var score

func _ready():
	$Player.hide();
	pass

func game_over():
	$mobTimer.stop()
	$HUD.show_game_over()

func new_game():
	score = 0
	$Player.show()
	$Player.start($startPosition.position)
	$startTimer.start()
	$HUD.update_score(score)

func _on_start_timer_timeout():
	$mobTimer.start()

func _on_mob_timer_timeout():
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()

	# Choose a random location on Path2D.
	var mob_spawn_location = $mobPath/mobSpawnLocation
	mob_spawn_location.progress_ratio = randf()

	# Set the mob's position to the random location.
	mob.position = mob_spawn_location.position

	# Set the mob's direction perpendicular to the path direction.
	var direction = mob_spawn_location.rotation - PI / 2

	# Add some randomness to the direction.
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction

	# Choose the velocity for the mob.
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	# Spawn the mob by adding it to the Main scene.
	# add_child(mob)

func _on_hud_start_game():
	new_game()


func _on_player_eat(tile: TileData) -> void:
	var is_point = tile.get_custom_data('is_point')  # Check if the tile is a point.
	var score_increment = tile.get_custom_data('score_increment')  # Default to 1 if not set.
	if is_point and score_increment:
		score += score_increment
		$HUD.update_score(score)

func _on_player_step_portal(cell: Vector2i) -> void:
	var cells = $Level/TileMapLayer.get_used_cells()
	var exit_portal_cell = Vector2i.ZERO
	for c in cells:
		var tile_data = $Level/TileMapLayer.get_cell_tile_data(c)
		if tile_data.get_custom_data('is_portal') and cell != c:
			print(c)
			exit_portal_cell = c
			break
	var exit_portal_position = $Level/TileMapLayer.map_to_local(exit_portal_cell)
	$Player.global_position = $Level/TileMapLayer.to_global(exit_portal_position)
