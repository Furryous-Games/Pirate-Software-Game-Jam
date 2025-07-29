extends Node2D

var terminal_3_toggled: bool = false
var terminal_4_toggled: bool = false

@onready var main_script : Node2D = $"../../"
@onready var main_platforms: TileMapLayer = $"Tilemaps/Main Platforms"
@onready var water_layer = $"Tilemaps/Water Layer"



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
		Vector2i(5, 1): room_spawn = Vector2i(4320, 980)
		Vector2i(5,-1): room_spawn = Vector2i(4320, 980)
		Vector2i(5, 2): room_spawn = Vector2i(4320, 980)
		Vector2i(5,-2): room_spawn = Vector2i(4320, 980)
		Vector2i(6, 0): room_spawn = Vector2i(4320, 980)
		Vector2i(6, 1): room_spawn = Vector2i(4320, 980)
		Vector2i(6,-1): room_spawn = Vector2i(4320, 980)
		Vector2i(6, 2): room_spawn = Vector2i(4320, 980)
		Vector2i(6,-2): room_spawn = Vector2i(4320, 980)
		Vector2i(7, 0): room_spawn = Vector2i(4320, 980)
		Vector2i(7, 1): room_spawn = Vector2i(4320, 980)
		Vector2i(7,-1): room_spawn = Vector2i(4320, 980)
		Vector2i(7, 2): room_spawn = Vector2i(4320, 980)
		Vector2i(7,-2): room_spawn = Vector2i(4320, 980)
		_: room_spawn = Vector2i(80,300)
	return room_spawn
	
func _enable_timer(initial_value: int, function_on_timeout = null):
	main_script.toggle_timer(true, initial_value, Color.FIREBRICK, function_on_timeout)

func _disable_timer():
	main_script.toggle_timer(false)

func _officer_terminal_interacted():
	# Handles the initial interaction with the officer
	_enable_timer(60, _officer_battle_timeout)

func _officer_battle_timeout():
	print("TIMEOUT")
	# Disable the timer
	_disable_timer()
	
	# Kill the player
	main_script.player.death()

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
	
	if terminal_4_toggled:
		
		get_node("Doors/P2/Door 3").toggle_door(true)
	
	terminal_3_toggled = true
	
	
	
func p2_wall_terminal_4_toggle() -> void:
	
	if terminal_3_toggled:
	
		get_node("Doors/P2/Door 3").toggle_door(true)
	
	terminal_4_toggled = true
	
func operator_server_water() -> void:
	
	get_node("Doors/Operator/Door 4").toggle_door(false)
	get_node("Doors/Operator/Door 5").toggle_door(true)
	get_node("Doors/Operator/Door 6").toggle_door(true)
	
	fill_waterfall(Vector2i(159, 33), Vector2i(18,1))
	
	drain_water(Vector2i(146, 18))
	
	fill_water_bottom(Vector2i(156, 48), Vector2i(18,1))
	
func drain_water(layer_coordinate):
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

		# Delays removing the next layer
		get_tree().create_timer(0.3).timeout.connect(drain_water.bind(layer_coordinate + Vector2i(0, 1)))

func fill_water_bottom(layer_coordinate, atlas_coord):
	# Only fills layers that are empty
	if main_platforms.get_cell_atlas_coords(layer_coordinate) == Vector2i(-1, -1):
		# Fill the layer
		fill_water_layer(layer_coordinate, atlas_coord)

		# Sets the next layer
		get_tree().create_timer(0.3).timeout.connect(fill_water_bottom.bind(layer_coordinate - Vector2i(0, 1), atlas_coord))
	
	
func fill_water_layer(layer_coordinate, atlas_coord):
	# Sets the host cell
	water_layer.set_cell(layer_coordinate, 1, atlas_coord)

	var check_pos = layer_coordinate - Vector2i(1, 0)

	# Sets to the left of the host cell
	for i in range(100):
		if main_platforms.get_cell_atlas_coords(check_pos) == Vector2i(-1, -1):
			water_layer.set_cell(check_pos, 1, atlas_coord)
			check_pos -= Vector2i(1, 0)
		else:
			break

	check_pos = layer_coordinate + Vector2i(1, 0)

	# Sets to the right of the host cell
	for i in range(100):
		if main_platforms.get_cell_atlas_coords(check_pos) == Vector2i(-1, -1):
			water_layer.set_cell(check_pos, 1, atlas_coord)
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
	water_layer.set_cell(layer_coordinate, 1, atlas_coord)

	var check_pos = layer_coordinate - Vector2i(1, 0)

	# Sets to the left of the host cell
	for i in 2:
		if main_platforms.get_cell_atlas_coords(check_pos) == Vector2i(-1, -1):
			water_layer.set_cell(check_pos, 1, atlas_coord)
			check_pos -= Vector2i(1, 0)
		else:
			break

	check_pos = layer_coordinate + Vector2i(1, 0)

	# Sets to the right of the host cell
	for i in 3:
		if main_platforms.get_cell_atlas_coords(check_pos) == Vector2i(-1, -1):
			water_layer.set_cell(check_pos, 1, atlas_coord)
			check_pos += Vector2i(1, 0)
		else:
			break
