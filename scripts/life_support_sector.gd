extends Node2D


const ROOM_SPAWN_DATA = {
		Vector2i(0,0): Vector2i(80,300),
		Vector2i(1,0): Vector2i(580, 300),
		Vector2i(2,0): Vector2i(1160, 300),
		Vector2i(3,0): Vector2i(1740, 200),
		Vector2i(3,1): Vector2i(1740, 200),
		Vector2i(3,-1): Vector2i(1740, 200),
}

func clear_tiles(coord, tile_map_layer) -> void:
	
	if tile_map_layer.get_cell_atlas_coords(coord) == Vector2i(18,1):
		tile_map_layer.erase_cell(coord)
		for tile in tile_map_layer.get_surrounding_cells(coord):
			clear_tiles(tile, tile_map_layer)
	
	pass

func p1_water_drain() -> void:
	
	var water_layer: TileMapLayer = get_node("Tilemaps/Water Layer")
	
	clear_tiles(Vector2(110,17), water_layer)
	
	get_node("Doors/P1/Door 1").toggle_door(true)

	pass
	
func p1_door_toggle() -> void:
	
	get_node("Doors/P1/Door 2").toggle_door(true)
	
	pass
