extends Node2D

@onready var main_script: Node2D = $"../../"

@onready var timing_mechanism_tick_1: TileMapLayer = $"Tilemaps/Mechanism Tick 1"
@onready var timing_mechanism_tick_2: TileMapLayer = $"Tilemaps/Mechanism Tick 2"
@onready var timing_mechanism_tick_3: TileMapLayer = $"Tilemaps/Mechanism Tick 3"
@onready var timing_mechanism_tick_4: TileMapLayer = $"Tilemaps/Mechanism Tick 4"
@onready var timing_mechanism_tick_5: TileMapLayer = $"Tilemaps/Mechanism Tick 5"
@onready var timing_mechanism_tick_6: TileMapLayer = $"Tilemaps/Mechanism Tick 6"
@onready var timing_mechanism_tick_7: TileMapLayer = $"Tilemaps/Mechanism Tick 7"
@onready var timing_mechanism_tick_8: TileMapLayer = $"Tilemaps/Mechanism Tick 8"
@onready var timing_mechanism_tick_9: TileMapLayer = $"Tilemaps/Mechanism Tick 9"

@onready var timing_mechanism_platforms: Node2D = $"Timing Mechanism Platforms"

@onready var main_platforms: TileMapLayer = $"Tilemaps/Main Platforms"
@onready var death_layer: TileMapLayer = $"Tilemaps/Death Layer"

var all_timing_mechanism_platforms
var curr_timing_mechanism_tick = -1


func _ready() -> void:
	all_timing_mechanism_platforms = [
		timing_mechanism_tick_1, 
		timing_mechanism_tick_2, 
		timing_mechanism_tick_3, 
		timing_mechanism_tick_4, 
		timing_mechanism_tick_5, 
		timing_mechanism_tick_6, 
		timing_mechanism_tick_7, 
		timing_mechanism_tick_8, 
		timing_mechanism_tick_9
		]
	
	_on_timing_mechanism_tick()
	
	# Fill the water in the coolant room
	fill_water_layer(Vector2i(210, 11), Vector2i(19, 1))
	fill_water(Vector2i(210, 12), Vector2i(18, 1))
	
	print(main_script)


func get_room_spawn_position(room: Vector2i = Vector2i.ZERO) -> Vector2i:
	var room_spawn: Vector2i
	match room:
		# Entrance Room
		Vector2i(0, 0): room_spawn = Vector2i(160, 120)
		# T1
		Vector2i(1, 0): room_spawn = Vector2i(640, 120)
		# T2
		Vector2i(2, 0): room_spawn = Vector2i(1200, 120)
		# P1
		Vector2i(3, 0): room_spawn = Vector2i(1790, 280)
		Vector2i(3, -1): room_spawn = Vector2i(1790, 280)
		# P2
		Vector2i(4, 0): room_spawn = Vector2i(2620, 280)
		Vector2i(4, -1): room_spawn = Vector2i(2620, 280)
		Vector2i(5, -1): room_spawn = Vector2i(2620, 280)
		# Decontamination
		Vector2i(5, 0): room_spawn = Vector2i(2960, 280)
		# Officer Room
		Vector2i(6, 0): room_spawn = Vector2i(3830, 160)
		Vector2i(6, -1): room_spawn = Vector2i(3830, 160)
		Vector2i(7, 0): room_spawn = Vector2i(3830, 160)
		Vector2i(7, -1): room_spawn = Vector2i(3830, 160)
	return room_spawn


func enable_platform_layer(platform_layer: TileMapLayer, enable: bool):
	platform_layer.visible = enable
	platform_layer.collision_enabled = enable


## WATER HANDLING FUNCTIONS
func drain_water(layer_coordinate):
	var check_pos = layer_coordinate - Vector2i(1, 0)
	
	# Removes to the left of the host cell
	for i in range(100):
		if death_layer.get_cell_atlas_coords(check_pos) != Vector2i(-1, -1):
			death_layer.erase_cell(check_pos)
			check_pos -= Vector2i(1, 0)
		else:
			break
	
	check_pos = layer_coordinate + Vector2i(1, 0)
	
	# Removes to the right of the host cell
	for i in range(100):
		if death_layer.get_cell_atlas_coords(check_pos) != Vector2i(-1, -1):
			death_layer.erase_cell(check_pos)
			check_pos += Vector2i(1, 0)
		else:
			break
	
	if death_layer.get_cell_atlas_coords(layer_coordinate) != Vector2i(-1, -1):
		# Removes the host cell
		death_layer.erase_cell(layer_coordinate)
		
		# Delays removing the next layer
		get_tree().create_timer(0.3).timeout.connect(drain_water.bind(layer_coordinate + Vector2i(0, 1)))

func fill_water(layer_coordinate, atlas_coord):
	# Only fills layers that are empty
	if main_platforms.get_cell_atlas_coords(layer_coordinate) == Vector2i(-1, -1):
		# Fill the layer
		fill_water_layer(layer_coordinate, atlas_coord)
		
		# Sets the next layer
		fill_water(layer_coordinate + Vector2i(0, 1), atlas_coord)
func fill_water_layer(layer_coordinate, atlas_coord):
	# Sets the host cell
	death_layer.set_cell(layer_coordinate, 1, atlas_coord)
	
	var check_pos = layer_coordinate - Vector2i(1, 0)
	
	# Sets to the left of the host cell
	for i in range(100):
		if main_platforms.get_cell_atlas_coords(check_pos) == Vector2i(-1, -1):
			death_layer.set_cell(check_pos, 1, atlas_coord)
			check_pos -= Vector2i(1, 0)
		else:
			break
	
	check_pos = layer_coordinate + Vector2i(1, 0)
	
	# Sets to the right of the host cell
	for i in range(100):
		if main_platforms.get_cell_atlas_coords(check_pos) == Vector2i(-1, -1):
			death_layer.set_cell(check_pos, 1, atlas_coord)
			check_pos += Vector2i(1, 0)
		else:
			break


## OFFICER FIGHT RESET
func reset_room():
	get_node("Boss Room").reset_battle()
	pass


## MECHANISM CLOCK FUNCTION
func _on_timing_mechanism_tick() -> void:
	# Tick the current mechanism frame
	curr_timing_mechanism_tick = (curr_timing_mechanism_tick + 1) % len(all_timing_mechanism_platforms)
	
	# Hide all platforms
	for platform in all_timing_mechanism_platforms:
		enable_platform_layer(platform, false)
	
	# Enable the current platform frame
	enable_platform_layer(all_timing_mechanism_platforms[curr_timing_mechanism_tick], true)
	
	# Tick all timing mechanism platforms
	for mechanical_room in timing_mechanism_platforms.get_children():
		for timing_platform in mechanical_room.get_children():
			timing_platform._on_timing_mechanism_tick()
