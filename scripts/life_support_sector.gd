extends Node2D

var terminal_3_toggled: bool = false
var terminal_4_toggled: bool = false


func get_room_spawn_position(room: Vector2i = Vector2i.ZERO) -> Vector2i:
	var room_spawn: Vector2i
	match room:
		Vector2i(0,0): room_spawn = Vector2i(80,300)
		Vector2i(1,0): room_spawn = Vector2i(600, 300)
		Vector2i(2,0): room_spawn = Vector2i(1160, 300)
		Vector2i(3,0): room_spawn = Vector2i(1760, 200)
		Vector2i(3,1): room_spawn = Vector2i(1760, 200)
		Vector2i(3,-1): room_spawn = Vector2i(1760, 200)
		Vector2i(4,0): room_spawn = Vector2i(2340,140)
		Vector2i(4,1): room_spawn = Vector2i(2340,140)
		Vector2i(4,-1): room_spawn = Vector2i(2340,140)
	return room_spawn


func clear_tiles(coord, atlas_coord, tile_map_layer) -> void:
	
	if tile_map_layer.get_cell_atlas_coords(coord) == atlas_coord:
		tile_map_layer.erase_cell(coord)
		for tile in tile_map_layer.get_surrounding_cells(coord):
			clear_tiles(tile, atlas_coord, tile_map_layer)
	
	

func p1_water_drain() -> void:
	
	var water_layer: TileMapLayer = get_node("Tilemaps/Water Layer")
	
	clear_tiles(Vector2(110,17), Vector2i(18,1), water_layer)
	
	get_node("Doors/P1/Door 1").toggle_door(true)

	
	
func p1_door_toggle() -> void:
	
	get_node("Doors/P1/Door 2").toggle_door(true)
	
	

func p2_wall_terminal_3_toggle() -> void:
	
	print(terminal_4_toggled)
	
	if terminal_4_toggled:
		
		get_node("Doors/P1/Door 3").toggle_door(true)
	
	terminal_3_toggled = true
	
	
	
func p2_wall_terminal_4_toggle() -> void:
	
	print(terminal_3_toggled)
	
	if terminal_3_toggled:
	
		get_node("Doors/P1/Door 3").toggle_door(true)
	
	terminal_4_toggled = true
	
	
