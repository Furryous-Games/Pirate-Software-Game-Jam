extends Node2D

signal recharge_dash

var current_subsector: String = "Main"
var subsector_platforms: Array[Node]
var subsector_recharges: Array[Node]
var is_launch_active := false
var is_officer_active := false

var subsector_terminal_data := {
	"Main": {"is_overheating": true, "is_terminal_activated": false},
	"Tutorial": {"is_overheating": true, "is_terminal_activated": false},
	"Puzzle1": {"is_overheating": true, "is_terminal_activated": false},
	"Puzzle2": {"is_overheating": true, "is_terminal_activated": false},
	"PostOfficer": {"is_overheating": false, "is_terminal_activated": false},
}

var officer_room_data := {
	"is_terminal_activated": {
		"Officer0": false,
		"Officer1": false,
		"Officer2": false,
	},
}

@onready var main_script: Node2D = $"../../"
@onready var dash_platforms: Node2D = $DashPlatforms
@onready var dash_recharges: Node2D = $DashRecharges
@onready var return_timer: Timer = $DashPlatforms/ReturnTimer
@onready var launch_boost_timeframe: Timer = $DashPlatforms/LaunchBoostTimeframe
@onready var doors: Node2D = $Doors
@onready var pre_officer_door: AnimatableBody2D = $Doors/Puzzle2


func _ready() -> void:
	# connects to signal emitted from player dash 
	main_script.player.player_dash.connect(func(): signal_dash())

	# connects recharge_dash signal to player
	self.recharge_dash.connect(main_script.player.recharge_dash)
	get_new_room_data()
	
	officer_room_data.doors = {
		"Officer0": $Doors/Officer0,
		"Officer1": [$Doors/Officer1a, $Doors/Officer1b],
		"Officer2": $Doors/Officer2,
		"OfficerEnd": $Doors/OfficerEnd,
	}


func get_new_room_data() -> void:
	reset_room()
	
	# If the player has not entered a new subsector -> return
	if current_subsector == get_subsector(main_script.current_room):
		return
	
	# Close the door behind the player when entering a new subsector
	if is_officer_active:
		if current_subsector == "Officer1":
			for door in officer_room_data.doors[current_subsector]:
				door.toggle_door(false)
		else:
			officer_room_data.doors[current_subsector].toggle_door(false)
	else:
		doors.find_child(current_subsector).toggle_door(false)
	
	# Gets the data for the room (section, mechanisms, sector spawn point)
	current_subsector = get_subsector(main_script.current_room)
	
	# Get an array of each dash platform and recharge node of the current subsector
	subsector_platforms.clear()
	if dash_platforms.find_child(current_subsector) != null:
		subsector_platforms = dash_platforms.find_child(current_subsector).get_children()
	
	subsector_recharges.clear()	
	if dash_recharges.find_child(current_subsector) != null:
		subsector_recharges = dash_recharges.find_child(current_subsector).get_children()
	
	if (is_officer_active or current_subsector == "Officer1"):
		if officer_room_data.is_terminal_activated[current_subsector]:
			for door in officer_room_data.doors[current_subsector]:
				door.toggle_door()
	else:
		# If the current subsector's terminal has already been activated -> reopen the door
		if subsector_terminal_data[current_subsector].is_terminal_activated:
			doors.find_child(current_subsector).toggle_door()

		# Turn on/off the minute timer and mirage when entering a room
		var is_subsector_overheating: bool = subsector_terminal_data[current_subsector].is_overheating
		if is_subsector_overheating != main_script.is_timer_active:
			main_script.toggle_timer(int(is_subsector_overheating), 60, Color.WHITE, main_script.reactor_timer_timout)
			main_script.toggle_mirage_shader(int(is_subsector_overheating))


func get_subsector(room: Vector2i = main_script.current_room) -> String:
	var subsector: String
	match room:
		Vector2i(0, 0): subsector = "Main"
		Vector2i(-1, 0): subsector = "Tutorial"
		Vector2i(-1,-1): subsector = "Tutorial"
		Vector2i(-2, -1): subsector = "Puzzle1"
		Vector2i(-3, -1): subsector = "Puzzle1"
		Vector2i(-3, -2): subsector = "Puzzle2"
		Vector2i(-2, -2): subsector = "Puzzle2"
		Vector2i(-1, -2): subsector = "Puzzle2"
		Vector2i(-1, -3): subsector = "Puzzle2"
		Vector2i(0, -4): subsector = "Officer0"
		Vector2i(0, -3): subsector = "Officer1"
		Vector2i(0, -2): subsector = "Officer2"
		Vector2i(0, -1): subsector = "Officer2"
		Vector2i(1, -3): subsector = "PostOfficer"
		Vector2i(1, -2): subsector = "PostOfficer"
		Vector2i(1, -1): subsector = "PostOfficer"
		Vector2i(1, 0): subsector = "PostOfficer"
	return subsector
	

func reset_room() -> void:
	return_timer.stop()
	launch_boost_timeframe.stop()
	is_launch_active = false
	for platform in subsector_platforms:
		platform.move(false, 0.2)
	for recharge in subsector_recharges:
		recharge.cooldown.stop()
		recharge.cooldown.timeout.emit()


func reset_officer() -> void:
	pass


func get_room_spawn_position(room: Vector2i = Vector2i.ZERO) -> Vector2i:
	var room_spawn: Vector2i
	match room:
		Vector2i(0, 0): room_spawn = Vector2i(280, 300) # Main
		Vector2i(-1, 0): room_spawn = Vector2i(-60, 300) # Tutorial 1
		Vector2i(-1,-1): room_spawn = Vector2i(-60, -25) # Tutorial 2
		Vector2i(-2, -1): room_spawn = Vector2i(-620, -40) # Puzzle 1a
		Vector2i(-3, -1): room_spawn = Vector2i(-1190, -225) # Puzzle 1b
		Vector2i(-3, -2): room_spawn = Vector2i(-1620, -385) # Puzzle 2a
		Vector2i(-2, -2): room_spawn = Vector2i(-1140, -400) # Puzzle 2b
		Vector2i(-1, -2): room_spawn = Vector2i(-560, -460) # Puzzle 2c
		Vector2i(-1, -3): room_spawn = Vector2i(-300, -725) # Puzzle 2d, Pre-Officer
		Vector2i(0, -4): room_spawn = Vector2i(520, -1065) # Officer 0
		Vector2i(0, -3): room_spawn = Vector2i(280, -725) # Officer 1
		Vector2i(0, -2): room_spawn = Vector2i(-300, -725) # Officer 2a
		Vector2i(0, -1): room_spawn = Vector2i(-300, -725) # Officer 2b
		_: room_spawn = Vector2i(280, 300) # Failsafe back to Main, Can't die during PostOfficer
	return room_spawn


func respawn_player_at_subsector() -> Vector2i:
	var subsector_spawn: Vector2i
	# Respawn at the end of the previous subsector
	match current_subsector:
		"Main": subsector_spawn = Vector2i(280, 300)
		"Tutorial": subsector_spawn = Vector2i(280, 300)
		"Puzzle1": subsector_spawn = Vector2i(-530, -40)
		"Puzzle2": subsector_spawn = Vector2i(-1620, -225)
		"Officer0": subsector_spawn = Vector2i(-300, -725)
		"Officer1": subsector_spawn = Vector2i(-300, -725)
		"Officer2": subsector_spawn = Vector2i(-300, -725)
		#"PostOfficer": subsector_spawn = Vector2i(-550, -40)
	if is_officer_active:
		reset_officer()
		is_officer_active = false
	return subsector_spawn


func signal_dash() -> void:
	# extend dash platforms
	for platform in subsector_platforms:
		platform.move(true)
	
	return_timer.start()
	launch_boost_timeframe.start()
	is_launch_active = true


func reactivate_cooling() -> void:
	# Only emit the signal if the subsector terminal has not already been activated
	if subsector_terminal_data[current_subsector].is_terminal_activated:
		return
	
	subsector_terminal_data[current_subsector].is_overheating = false
	subsector_terminal_data[current_subsector].is_terminal_activated = true
	
	main_script.toggle_timer(false)
	main_script.toggle_mirage_shader(false)
	
	doors.find_child(current_subsector).toggle_door()


func activate_officer_terminal() -> void:
	if officer_room_data.is_terminal_activated[current_subsector]:
		return
		
	officer_room_data.is_terminal_activated[current_subsector] = true
	officer_room_data.doors[current_subsector].toggle_door()
	


func _on_return_timer_timeout() -> void:
	# return dash platforms to their initial position
	for platform in subsector_platforms:
		platform.move(false)


func _on_launch_boost_timeframe_timeout() -> void:
	is_launch_active = false
