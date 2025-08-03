extends Node2D

var original_tiles = {}
var tilemap: TileMapLayer

func _ready():
	tilemap = get_node("TileMapLayer")
	var used_cells = tilemap.get_used_cells()
	for cell in used_cells:
		var id = tilemap.get_cell_source_id(cell)
		var atlas_coords = tilemap.get_cell_atlas_coords(cell)
		original_tiles[cell] = [id, atlas_coords]

func reset():
	for cell in original_tiles.keys():
		tilemap.set_cell(cell, original_tiles[cell][0], original_tiles[cell][1])
