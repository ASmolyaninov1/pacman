extends Node

static func snap_to_grid(position: Vector2, tilemap_layer: TileMapLayer = null) -> Vector2:
    var cell_pos = tilemap_layer.local_to_map(tilemap_layer.to_local(position))
    return tilemap_layer.to_global(tilemap_layer.map_to_local(cell_pos))