extends Node

@export var mob_scene: PackedScene
var score

func _ready():
	$Player.hide();
	pass

func game_over():
	$HUD.show_game_over()

func new_game():
	score = 0
	$Player.show()
	$Player.start($startPosition.position)
	$startTimer.start()
	$HUD.update_score(score)
	spawn_mob()

func spawn_mob():
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()

	# Choose a random location on Path2D.
	var mob_spawn_location = $mobStartPosition.position
	mob.global_position = mob_spawn_location
	# Spawn the mob by adding it to the Main scene.
	add_child(mob)

func _on_hud_start_game():
	new_game()


func _on_player_eat(tile: TileData) -> void:
	var is_point = tile.get_custom_data('is_point')  # Check if the tile is a point.
	var score_increment = tile.get_custom_data('score_increment')  # Default to 1 if not set.
	if is_point and score_increment:
		score += score_increment
		$HUD.update_score(score)

func _on_player_step_portal(cell: Vector2i) -> void:
	print("portal")
	var cells = $Level/TileMapLayer.get_used_cells()
	var exit_portal_cell = Vector2i.ZERO
	for c in cells:
		var tile_data = $Level/TileMapLayer.get_cell_tile_data(c)
		if tile_data.get_custom_data('is_portal') and cell != c:
			exit_portal_cell = c
			break
	var exit_portal_position = $Level/TileMapLayer.map_to_local(exit_portal_cell)
	$Player.global_position = $Level/TileMapLayer.to_global(exit_portal_position)
