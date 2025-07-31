extends Node2D

var terminal_1_toggled: bool = false
var terminal_2_toggled: bool = false
var terminal_3_toggled: bool = false
var terminal_4_toggled: bool = false
var server_toggle: bool = false
var gravity_disabeld: bool = false

@onready var main_script : Node2D = $"../../"
@onready var main_platforms: TileMapLayer = $"Tilemaps/Main Platforms"
@onready var water_layer: TileMapLayer = $"Tilemaps/Water Layer"


func get_room_spawn_position(room: Vector2i = Vector2i.ZERO) -> Vector2i:
	var room_spawn: Vector2i
	match room:
		Vector2i(0, 0): room_spawn = Vector2i(80,300)
		Vector2i(1, 0): room_spawn = Vector2i(600, 300)
		Vector2i(2, 0): room_spawn = Vector2i(1180, 300)
		Vector2i(3, 0): room_spawn = Vector2i(1760, 200)
		Vector2i(3, 1): room_spawn = Vector2i(1760, 200)
		Vector2i(3,-1): room_spawn = Vector2i(1760, 200)
		Vector2i(4, 0): room_spawn = Vector2i(2340, 160)
		Vector2i(4, 1): room_spawn = Vector2i(2340, 160)
		Vector2i(4,-1): room_spawn = Vector2i(2340, 160)
		Vector2i(5, 0): room_spawn = Vector2i(2940, 160)
		Vector2i(5, 1): room_spawn = Vector2i(3820, -620)
		Vector2i(5,-1): room_spawn = Vector2i(3820, -620)
		Vector2i(5, 2): room_spawn = Vector2i(3820, -620)
		Vector2i(5,-2): 
			if gravity_disabeld:
				room_spawn = Vector2i(3820, -600)
			else:
				room_spawn = Vector2i(2940, 160)
		Vector2i(6, 0): room_spawn = Vector2i(2940, 160)
		Vector2i(6, 1): room_spawn = Vector2i(4320, 980)
		Vector2i(6,-1): room_spawn = Vector2i(4320, 980)
		Vector2i(6, 2): room_spawn = Vector2i(4320, 980)
		Vector2i(6,-2): 
			if gravity_disabeld:
				room_spawn = Vector2i(3820, -600)
			else:
				room_spawn = Vector2i(2940, 160)
		Vector2i(7, 0): room_spawn = Vector2i(2940, 160)
		Vector2i(7, 1): room_spawn = Vector2i(4320, 980)
		Vector2i(7,-1): room_spawn = Vector2i(4320, 980)
		Vector2i(7, 2): room_spawn = Vector2i(4320, 980)
		Vector2i(7,-2): 
			if gravity_disabeld:
				room_spawn = Vector2i(3820, -600)
			else:
				room_spawn = Vector2i(2940, 160)
		_: room_spawn = Vector2i(80,300)
	return room_spawn
	
func get_subsector(room: Vector2i = main_script.current_room) -> String:
	var subsector: String
	match room:
		Vector2i(0, 0): subsector = "Main"
		Vector2i(1, 0): subsector = "Tutorial 1"
		Vector2i(2, 0): subsector = "Tutorial 2"
		Vector2i(3, -1): subsector = "Puzzle 1"
		Vector2i(3, 0): subsector = "Puzzle 1"
		Vector2i(3, 1): subsector = "Puzzle 1"
		Vector2i(4, -1): subsector = "Puzzle 2"
		Vector2i(4, 0): subsector = "Puzzle 2"
		Vector2i(4, 1): subsector = "Puzzle 2"
		_: subsector = "Officer"
	return subsector


func clear_tiles(coord, atlas_coord, tile_map_layer) -> void:
	
	if tile_map_layer.get_cell_atlas_coords(coord) == atlas_coord:
		tile_map_layer.erase_cell(coord)
		for tile in tile_map_layer.get_surrounding_cells(coord):
			clear_tiles(tile, atlas_coord, tile_map_layer)


func p1_water_drain() -> void:
	
	#var water_layer: TileMapLayer = get_node("Tilemaps/Water Layer")
	
	clear_tiles(Vector2(110,17), Vector2i(10,2), water_layer)
	
	get_node("Doors/P1/Door 1").toggle_door(true)


func p1_door_toggle() -> void:
	
	get_node("Doors/P1/Door 2").toggle_door(true)


func p2_wall_terminal_3_toggle() -> void:
	
	if terminal_4_toggled:
		
		get_node("Doors/P2/Door 3").toggle_door(true)
	
	terminal_3_toggled = true


func p2_wall_terminal_4_toggle() -> void:
	
	if terminal_3_toggled:
	
		get_node("Doors/P2/Door 3").toggle_door(true)
	
	terminal_4_toggled = true


func server_terminal_toggle() -> void:
	server_toggle = true


func gravity_diabeld_toggle() -> void:
	if !gravity_disabeld:
		gravity_disabeld = true
	else:
		gravity_disabeld = false


func drain_water(layer_coordinate, delay: bool = true):
	var check_pos = layer_coordinate - Vector2i(1, 0)
	
	# Removes to the left of the host cell
	for i in range(100):
		if water_layer.get_cell_atlas_coords(check_pos) != Vector2i(-1, -1):
			water_layer.erase_cell(check_pos)
			check_pos -= Vector2i(1, 0)
		else:
			break

	check_pos = layer_coordinate + Vector2i(1, 0)

	# Removes to the right of the host cell
	for i in range(100):
		if water_layer.get_cell_atlas_coords(check_pos) != Vector2i(-1, -1):
			water_layer.erase_cell(check_pos)
			check_pos += Vector2i(1, 0)
		else:
			break

	if water_layer.get_cell_atlas_coords(layer_coordinate) != Vector2i(-1, -1):
		# Removes the host cell
		water_layer.erase_cell(layer_coordinate)
		
		if delay:
			# Delays removing the next layer
			get_tree().create_timer(0.3).timeout.connect(drain_water.bind(layer_coordinate + Vector2i(0, 1)))
		else:
			drain_water(layer_coordinate + Vector2i(0, 1))


func fill_water_top(layer_coordinate, atlas_coord):
	# Only fills layers that are empty
	if main_platforms.get_cell_atlas_coords(layer_coordinate) == Vector2i(-1, -1):
		# Fill the layer
		fill_water_layer(layer_coordinate, atlas_coord)
		
		# Sets the next layer
		fill_water_top(layer_coordinate + Vector2i(0, 1), atlas_coord)


func fill_water_bottom(layer_coordinate, atlas_coord):
	# Only fills layers that are empty
	if main_platforms.get_cell_atlas_coords(layer_coordinate) == Vector2i(-1, -1):
		# Fill the layer
		fill_water_layer(layer_coordinate, atlas_coord)

		# Sets the next layer
		get_tree().create_timer(0.3).timeout.connect(fill_water_bottom.bind(layer_coordinate - Vector2i(0, 1), atlas_coord))


func fill_water_layer(layer_coordinate, atlas_coord):
	# Sets the host cell
	water_layer.set_cell(layer_coordinate, 0, atlas_coord)

	var check_pos = layer_coordinate - Vector2i(1, 0)

	# Sets to the left of the host cell
	for i in range(100):
		if main_platforms.get_cell_atlas_coords(check_pos) == Vector2i(-1, -1):
			water_layer.set_cell(check_pos, 0, atlas_coord)
			check_pos -= Vector2i(1, 0)
		else:
			break

	check_pos = layer_coordinate + Vector2i(1, 0)

	# Sets to the right of the host cell
	for i in range(100):
		if main_platforms.get_cell_atlas_coords(check_pos) == Vector2i(-1, -1):
			water_layer.set_cell(check_pos, 0, atlas_coord)
			check_pos += Vector2i(1, 0)
		else:
			break


func fill_waterfall(layer_coordinate, atlas_coord):
	# Only fills layers that are empty
	if main_platforms.get_cell_atlas_coords(layer_coordinate) == Vector2i(-1, -1):
		# Fill the layer
		fill_waterfall_layer(layer_coordinate, atlas_coord)

		# Sets the next layer
		get_tree().create_timer(0.3).timeout.connect(fill_waterfall.bind(layer_coordinate + Vector2i(0, 1), atlas_coord))


func fill_waterfall_layer(layer_coordinate, atlas_coord):
	# Sets the host cell
	water_layer.set_cell(layer_coordinate, 0, atlas_coord)

	var check_pos = layer_coordinate - Vector2i(1, 0)

	# Sets to the left of the host cell
	for i in 2:
		if main_platforms.get_cell_atlas_coords(check_pos) == Vector2i(-1, -1):
			water_layer.set_cell(check_pos, 0, atlas_coord)
			check_pos -= Vector2i(1, 0)
		else:
			break

	check_pos = layer_coordinate + Vector2i(1, 0)

	# Sets to the right of the host cell
	for i in 3:
		if main_platforms.get_cell_atlas_coords(check_pos) == Vector2i(-1, -1):
			water_layer.set_cell(check_pos, 0, atlas_coord)
			check_pos += Vector2i(1, 0)
		else:
			break
