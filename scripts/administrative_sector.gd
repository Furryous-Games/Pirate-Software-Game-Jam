extends Node2D

@onready var main_script: Node2D = $"../../"
@onready var effects_hud: VBoxContainer = $"../../UI/Effects"

@onready var timing_mechanism_tick_1: TileMapLayer = $"Tilemaps/Mechanism Tick 1"
@onready var timing_mechanism_tick_2: TileMapLayer = $"Tilemaps/Mechanism Tick 2"
@onready var timing_mechanism_tick_3: TileMapLayer = $"Tilemaps/Mechanism Tick 3"
@onready var timing_mechanism_tick_4: TileMapLayer = $"Tilemaps/Mechanism Tick 4"
@onready var timing_mechanism_tick_5: TileMapLayer = $"Tilemaps/Mechanism Tick 5"
@onready var timing_mechanism_tick_6: TileMapLayer = $"Tilemaps/Mechanism Tick 6"
@onready var timing_mechanism_tick_7: TileMapLayer = $"Tilemaps/Mechanism Tick 7"
@onready var timing_mechanism_tick_8: TileMapLayer = $"Tilemaps/Mechanism Tick 8"
@onready var timing_mechanism_tick_9: TileMapLayer = $"Tilemaps/Mechanism Tick 9"
@onready var dash_platforms: Array[Node] = $"Dash Platforms".get_children()
@onready var launch_boost_timeframe: Timer = $LaunchBoostTimeframe
@onready var return_timer: Timer = $ReturnTimer

@onready var timing_mechanism_platforms: Node2D = $"Timing Mechanism Platforms"

@onready var timed_gravity_flip: Timer = $"Timed Gravity Flip"
@onready var timed_dash_action: Timer = $"Timed Dash Action"

var all_timing_mechanism_platforms
var curr_timing_mechanism_tick = -1
var is_launch_active: = false

func get_room_spawn_position(room: Vector2i = Vector2i.ZERO) -> Vector2i:
	var room_spawn: Vector2i
	match room:
		# Entrance Room
		Vector2i(0, 0): room_spawn = Vector2i(290, 190)
		# Tutorial Room
		Vector2i(1, 0): room_spawn = Vector2i(800, 260)
		Vector2i(1, -1): room_spawn = Vector2i(800, 260)
		# P1 Room
		Vector2i(1, -2): room_spawn = Vector2i(380, -60)
		Vector2i(0, -1): room_spawn = Vector2i(380, -60)
		Vector2i(0, -2): room_spawn = Vector2i(380, -60)
		Vector2i(0, -3): room_spawn = Vector2i(380, -60)
		Vector2i(0, -4): room_spawn = Vector2i(380, -60)
		Vector2i(1, -3): room_spawn = Vector2i(380, -60)
		Vector2i(1, -4): room_spawn = Vector2i(380, -60)
		# P2 Room
		Vector2i(-1, -4): room_spawn = Vector2i(-50, -1060)
		Vector2i(-2, -4): room_spawn = Vector2i(-50, -1060)
		_: room_spawn = Vector2i(-50, -1060) #TODO Changge to spawn door
	return room_spawn


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
	
	# Tick the engineering mechanisms
	_on_timing_mechanism_tick()
	
	# Set the timers for the effects hud
	effects_hud.make_new_ability("Gravity Flip", timed_gravity_flip)
	effects_hud.make_new_ability("Dash Action", timed_dash_action)


## ENGINEERING FUNCTIONS
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


func enable_platform_layer(platform_layer: TileMapLayer, enable: bool):
	platform_layer.visible = enable
	platform_layer.collision_enabled = enable


## LIFE SUPPORT FUNCTIONS


## REACTOR FUNCTIONS
func signal_dash() -> void:
	pass

	# extend dash platforms
	for platform in dash_platforms:
		platform.move(true)
	#
	return_timer.start()
	launch_boost_timeframe.start()
	is_launch_active = true


func _on_return_timer_timeout() -> void:
	# return dash platforms to their initial position
	for platform in dash_platforms:
		platform.move(false)


func _on_launch_boost_timeframe_timeout() -> void:
	is_launch_active = false
