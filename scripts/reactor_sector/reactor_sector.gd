extends Node2D

signal recharge_dash

const SUBSECTOR_DATA := {
	"Main": {"mechanisms": -1, "spawn_point": Vector2i(280, 300)},
	"Tutorial": {"mechanisms": 0, "spawn_point": Vector2i(300, 300)},
	"Puzzle1": {"mechanisms": 1, "spawn_point": Vector2i(-550, -40)},
	"Puzzle2": {"mechanisms": 2, "spawn_point": Vector2i(-1620, -385)},
	"Boss": {"mechanisms": 3, "spawn_point": Vector2i(-550, -40)},
	"PostBoss": {"mechanisms": -1, "spawn_point": Vector2i(-550, -40)},
}

var current_subsector: String
var active_subsector_mechanisms: int
var is_launch_active := false

var subsector_terminal_data := {
	"Main": {"is_overheating": true, "is_terminal_activated": false},
	"Tutorial": {"is_overheating": true, "is_terminal_activated": false},
	"Puzzle1": {"is_overheating": true, "is_terminal_activated": false},
	"Puzzle2": {"is_overheating": true, "is_terminal_activated": false},
	"Boss": {"is_overheating": true, "is_terminal_activated": false},
	"PostBoss": {"is_overheating": false, "is_terminal_activated": false},
}

@onready var main_script: Node2D = $"../../"
@onready var dash_platforms: Node2D = $DashPlatforms
@onready var return_timer: Timer = $ReturnTimer


func _ready() -> void:
	# connects to signal emitted from player dash 
	main_script.player.player_dash.connect(func(): signal_dash())

	# connects recharge_dash signal to player
	self.recharge_dash.connect(main_script.player.recharge_dash)
	get_new_room_data()


func get_new_room_data() -> void:
	# Gets the data for the room (section, mechanisms, sector spawn point)
	# BUG: Invalid access to property or key '(0, -1)' on a base object of type 'Dictionary' On timeout at (-1, -1)
	current_subsector = get_subsector(main_script.current_room)
	reset_room()
	
	# Turn on/off the minute timer and mirage when entering a room
	var is_subsector_overheating: bool = subsector_terminal_data[current_subsector].is_overheating
	if is_subsector_overheating != main_script.is_timer_active:
		main_script.toggle_timer(int(is_subsector_overheating), 60, Color.WHITE, main_script.reactor_timer_timout)
		main_script.toggle_mirage_shader(int(is_subsector_overheating))


func get_subsector(room: Vector2i = main_script.current_room) -> String:
	var subsector: String
	match room:
		Vector2i(0, 0): subsector =  "Main"
		Vector2i(-1, 0): subsector =  "Tutorial"
		Vector2i(-1,-1): subsector =  "Tutorial"
		Vector2i(-2, -1): subsector =  "Puzzle1"
		Vector2i(-3, -1): subsector =  "Puzzle1"
		Vector2i(-3, -2): subsector =  "Puzzle2"
		Vector2i(-2, -2): subsector =  "Puzzle2"
		Vector2i(-1, -2): subsector =  "Puzzle2"
		Vector2i(-1, -3): subsector =  "Puzzle2"
		Vector2i(0, -4): subsector = "Boss"
		Vector2i(0, -3): subsector = "Boss"
		Vector2i(0, -2): subsector = "Boss"
		Vector2i(0, -1): subsector = "Boss"
		Vector2i(1, -3): subsector = "PostBoss"
		Vector2i(1, -2): subsector = "PostBoss"
		Vector2i(1, -1): subsector = "PostBoss"
		Vector2i(1, 0): subsector = "PostBoss"
	return subsector
	

func reset_room() -> void:
	return_timer.stop()
	for platform in dash_platforms.get_child(active_subsector_mechanisms).get_children():
		platform.reset()


func get_room_spawn_position(room: Vector2i = Vector2i.ZERO) -> Vector2i:
	var room_spawn: Vector2i
	match room:
		Vector2i(0, 0): room_spawn = Vector2i(280, 300) # Main
		Vector2i(-1, 0): room_spawn = Vector2i(-60, 300) # Tutorial 1
		Vector2i(-1,-1): room_spawn = Vector2i(-60, -25) # Tutorial 2
		Vector2i(-2, -1): room_spawn = Vector2i(-620, -40) # Puzzle 1a
		Vector2i(-3, -1): room_spawn = Vector2i(-1190, -225) # Puzzle 1b
		Vector2i(-3, -2): room_spawn = Vector2i(-1620, -385) # Puzzle 2a
		Vector2i(-2, -2): room_spawn = Vector2i(-1620, -385) # Puzzle 2b
		Vector2i(-1, -2): room_spawn = Vector2i(-1620, -385) # Puzzle 2c
		Vector2i(-1, -3): room_spawn = Vector2i(-300, -725) # Puzzle 2d, Pre-Boss
		Vector2i(0, -4): room_spawn = Vector2i(-1190, -225) # Boss (0, 1)
		Vector2i(0, -3): room_spawn = Vector2i(-1190, -225) # Boss (0, 0)
		Vector2i(0, -2): room_spawn = Vector2i(-1190, -225) # Boss (0, -1)
		Vector2i(0, -1): room_spawn = Vector2i(-1190, -225) # Boss (0, -2)
		# Cannot die during PostBoss
		#Vector2i(1, -3): room_spawn = Vector2i(-1190, -225) # PostBoss (0, 0)
		#Vector2i(1, -2): room_spawn = Vector2i(-1190, -225) # PostBoss (0, -1)
		#Vector2i(1, -1): room_spawn = Vector2i(-1190, -225) # PostBoss (0, -2)
		#Vector2i(1, 0): room_spawn = Vector2i(-1190, -225) # PostBoss (0, -3)
	return room_spawn


func signal_dash() -> void:
	# mechanisms: -1 have no mechanisms 
	if SUBSECTOR_DATA[current_subsector].mechanisms == -1:
		return
	
	# get current room to activate their dash platforms
	active_subsector_mechanisms = SUBSECTOR_DATA[current_subsector].mechanisms
	# extend dash platforms
	for platform in dash_platforms.get_child(active_subsector_mechanisms).get_children():
		platform.move(true)
	return_timer.start()
	
	is_launch_active = true


func reactivate_cooling() -> void:
	subsector_terminal_data[current_subsector].is_overheating = false
	subsector_terminal_data[current_subsector].is_terminal_activated = true
	main_script.toggle_timer(false)
	main_script.toggle_mirage_shader(false)


func respawn_player_at_subsector() -> Vector2i:
	return SUBSECTOR_DATA[current_subsector].spawn_point


func _on_return_timer_timeout() -> void:
	# return dash platforms to their initial position
	for platform in dash_platforms.get_child(active_subsector_mechanisms).get_children():
		platform.move(false)
