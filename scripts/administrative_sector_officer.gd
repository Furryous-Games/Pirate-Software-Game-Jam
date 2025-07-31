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

@onready var timing_mechanism_platforms: Node2D = $"Timing Mechanism Platforms"

@onready var timed_gravity_flip: Timer = $"Timed Gravity Flip"
@onready var timed_dash_action: Timer = $"Timed Dash Action"

var all_timing_mechanism_platforms
var curr_timing_mechanism_tick = -1

func get_room_spawn_position(room: Vector2i = Vector2i.ZERO) -> Vector2i:
	var room_spawn: Vector2i
	match room:
		# Officer Room
		Vector2i(0, 0): room_spawn = Vector2i(290, 220)
		# Engineering Room
		Vector2i(-1, 0): room_spawn = Vector2i(290, 220)
		Vector2i(-1, 1): room_spawn = Vector2i(290, 220)
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
	for timing_platform in timing_mechanism_platforms.get_children():
		timing_platform._on_timing_mechanism_tick()
func enable_platform_layer(platform_layer: TileMapLayer, enable: bool):
	platform_layer.visible = enable
	platform_layer.collision_enabled = enable

## TIMER TOGGLING FUNCTIONS
func _enable_timer(initial_value: int, function_on_timeout = null):
	main_script.toggle_timer(true, initial_value, Color.WHITE, function_on_timeout)
func _disable_timer():
	main_script.toggle_timer(false)

## TUTORIAL
func t_dash() -> void:
	timed_dash_action.wait_time = 10
	timed_dash_action.start()

func _gravity_flip(wait_time: int = 10) -> void:
	# Flip the gravity if the timer is disabled
	if timed_gravity_flip.is_stopped():
		main_script.player.gravity_invert()
	
	# Set the new wait time
	timed_gravity_flip.wait_time = wait_time
	
	# Restart the timer
	timed_gravity_flip.start()

func _gravity_flip_timeout() -> void:
	print("FLIP BACK")
	if main_script.player.gravity_change == -1:
		# Flip the gravity back
		main_script.player.gravity_invert()
	
	# Restart the timer
	timed_gravity_flip.stop()
	

## P1
func _start_p1_timer():
	_enable_timer(60, _p1_timer_timeout)
	timed_dash_action.wait_time = 60
	timed_dash_action.start()

func _p1_timer_timeout():
	print("TIMEOUT")
	timed_dash_action.stop()
	
func _p1_exit():
	get_node("../Doors/P1 Exit door").timed_toggle(15, true)

## REACTOR FUNCTIONS
func signal_dash() -> void:
	pass
