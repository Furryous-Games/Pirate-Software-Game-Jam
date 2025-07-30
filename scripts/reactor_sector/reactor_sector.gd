extends Node2D

var current_subsector: StringName = &"Main"
var close_subsector: StringName
var subsector_platforms: Array[Node]
var subsector_recharges: Array[Node]
var is_launch_active := false
var is_officer_active := false
var is_officer_interaction_initial := true

var subsector_terminal_data := {
	&"Main": {&"is_overheating": true, &"is_terminal_online": false},
	&"Tutorial": {&"is_overheating": true, &"is_terminal_online": false},
	&"Puzzle1": {&"is_overheating": true, &"is_terminal_online": false},
	&"Puzzle2": {&"is_overheating": true, &"is_terminal_online": false},
	&"Officer0": {&"is_terminal_online": false},
	&"Officer1": {&"is_terminal_online": false},
	&"Officer2": {&"is_terminal_online": false},
	&"Elevator": {&"is_terminal_online": false},
}

@onready var main_script: Node2D = $"../../"
@onready var dash_platforms: Node2D = $DashPlatforms
@onready var dash_recharges: Node2D = $DashRecharges
@onready var return_timer: Timer = $DashPlatforms/ReturnTimer
@onready var launch_boost_timeframe: Timer = $DashPlatforms/LaunchBoostTimeframe
@onready var terminals: Node2D = $Terminals
@onready var doors: Node2D = $Doors
@onready var open_officer1_doors := {&"Officer1a": $"Doors/Officer1a", &"Officer1b": $"Doors/Officer1b"}
@onready var officer_base: Area2D = $ReactorOfficer


func _ready() -> void:
	get_new_room_data()


func get_new_room_data() -> void:
	reset_room()
	
	# If the player has not entered a new subsector -> return
	if current_subsector == get_subsector(main_script.current_room):
		return
	
	close_subsector = current_subsector
	# Gets the data for the room (section, mechanisms, sector spawn point)
	current_subsector = get_subsector(main_script.current_room)
	
	toggle_subsector_doors()
	
	# Get an array of each dash platform node of the current subsector
	subsector_platforms.clear()
	if dash_platforms.find_child(current_subsector) != null:
		subsector_platforms = dash_platforms.find_child(current_subsector).get_children()
	
	# Get an array of each recharge node of the current subsector
	subsector_recharges.clear()	
	if dash_recharges.find_child(current_subsector) != null:
		subsector_recharges = dash_recharges.find_child(current_subsector).get_children()


func get_subsector(room: Vector2i = main_script.current_room) -> String:
	var subsector: String
	match room:
		Vector2i(0, 0): subsector = &"Main"
		Vector2i(-1, 0): subsector = &"Tutorial"
		Vector2i(-1,-1): subsector = &"Tutorial"
		Vector2i(-2, -1): subsector = &"Puzzle1"
		Vector2i(-3, -1): subsector = &"Puzzle1"
		Vector2i(-3, -2): subsector = &"Puzzle2"
		Vector2i(-2, -2): subsector = &"Puzzle2"
		Vector2i(-1, -2): subsector = &"Puzzle2"
		Vector2i(-1, -3): subsector = &"Puzzle2"
		Vector2i(0, -4): subsector = &"Officer0"
		Vector2i(0, -3): subsector = &"Officer1"
		Vector2i(0, -2): subsector = &"Officer2"
		Vector2i(0, -1): subsector = &"Officer2"
		Vector2i(1, -3): subsector = &"Elevator"
		Vector2i(1, -2): subsector = &"Elevator"
		Vector2i(1, -1): subsector = &"Elevator"
		Vector2i(1, 0): subsector = &"Elevator"
	return subsector


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
		Vector2i(0, -3): room_spawn = Vector2i(290, -725) # Officer 1
		Vector2i(0, -2): room_spawn = Vector2i(60, -575) # Officer 2a
		Vector2i(0, -1): room_spawn = Vector2i(40, -205) # Officer 2b
		Vector2i(1, -3): room_spawn = Vector2i(870, -725) # Elevator
		Vector2i(1, -2): room_spawn = Vector2i(870, -725) # Elevator
		Vector2i(1, -1): room_spawn = Vector2i(870, -725) # Elevator
		Vector2i(1, 0): room_spawn = Vector2i(870, -725) # Elevator
		_: room_spawn = Vector2i(280, 300) # Failsafe back to Main
	return room_spawn


func respawn_player_at_subsector() -> Vector2i:
	var subsector_spawn: Vector2i
	# Respawn at the end of the previous subsector
	match current_subsector:
		&"Main": subsector_spawn = Vector2i(280, 300)
		&"Tutorial": subsector_spawn = Vector2i(280, 300)
		&"Puzzle1": subsector_spawn = Vector2i(-530, -40)
		&"Puzzle2": subsector_spawn = Vector2i(-1620, -255)
		&"Officer0": subsector_spawn = Vector2i(-300, -725)
		&"Officer1": subsector_spawn = Vector2i(-300, -725)
		&"Officer2": subsector_spawn = Vector2i(-300, -725)
		&"Elevator": subsector_spawn = Vector2i(870, -725)
	if is_officer_active:
		reset_officer()
	return subsector_spawn

	
func reset_room() -> void:
	return_timer.stop()
	launch_boost_timeframe.stop()
	is_launch_active = false
	# Reset platforms
	for platform in subsector_platforms:
		platform.move(false, 0.2)
	# Reset dash-recharges
	for recharge in subsector_recharges:
		recharge.cooldown.stop()
		recharge.cooldown.timeout.emit()


func reset_officer() -> void:
	main_script.toggle_timer(false)
	main_script.toggle_mirage_shader(false)
	is_officer_active = false
	is_officer_interaction_initial = true
	subsector_terminal_data.Officer0.is_terminal_online = false
	subsector_terminal_data.Officer2.is_terminal_online = false
	open_officer1_doors = {&"Officer1a": $"Doors/Officer1a", &"Officer1b": $"Doors/Officer1b"}
	for officer_door in [open_officer1_doors.Officer1a, open_officer1_doors.Officer1b, doors.find_child(&"Officer0"), doors.find_child(&"Officer2")]:
		officer_door.toggle_door(false)
	update_officer_terminal()

		
func toggle_subsector_doors() -> void:
	if current_subsector == &"Officer1":
		if is_officer_active:
			# Open the unlocked officer subsector doors
			for i in open_officer1_doors.keys():
				open_officer1_doors[i].toggle_door(true)
			# Close the officer subsector exit door
			doors.find_child(close_subsector).toggle_door(false)
		
		else: # Close the officer room exit doors
			doors.find_child(&"Puzzle2").toggle_door(false)
			doors.find_child(&"Officer1c").toggle_door(false)
	
	# Close the officer subsector door after entering
	elif close_subsector == &"Officer1" and is_officer_active:
		doors.find_child(&"Officer1a" if current_subsector == &"Officer0" else &"Officer1b").toggle_door(false)
	
	else:
		# BUG: Restarting at Officer0 returns null current_subsector
		
		# Reopen the door if the current subsector's terminal has already been activated
		if subsector_terminal_data[current_subsector].is_terminal_online:
			doors.find_child(current_subsector).toggle_door()
		
		# Only toggle timer and mirage if can be overheating
		if subsector_terminal_data[current_subsector].has(&"is_overheating"):
			var is_subsector_overheating: bool = subsector_terminal_data[current_subsector].is_overheating
			
			# Turn on/off the minute timer and mirage when entering a room
			if is_subsector_overheating != main_script.is_timer_active:
				main_script.toggle_timer(int(is_subsector_overheating), 60, Color.WHITE, func(): main_script.player.death(true))
				main_script.toggle_mirage_shader(int(is_subsector_overheating))
			
			# Close the previous door if the current subsector is overheating
			if is_subsector_overheating:
				doors.find_child(close_subsector).toggle_door(false)
		

func reactivate_cooling() -> void:
	# Only emit the signal if the subsector terminal has not already been activated
	if subsector_terminal_data[current_subsector].is_terminal_online:
		return
	
	# Disable subsector overheating and activated terminal
	subsector_terminal_data[current_subsector].is_overheating = false
	subsector_terminal_data[current_subsector].is_terminal_online = true
	terminals.find_child(current_subsector).key_prompt.text = "ONLINE"
	
	main_script.toggle_timer(false)
	main_script.toggle_mirage_shader(false)
	
	doors.find_child(current_subsector).toggle_door()


func activate_officer_terminal() -> void:
	# Only emit the signal if the subsector terminal has not already been activated
	if subsector_terminal_data[current_subsector].is_terminal_online:
		return
	
	# Activate the subsector terminal and open the door
	subsector_terminal_data[current_subsector].is_terminal_online = true
	terminals.find_child(current_subsector).key_prompt.text = "ONLINE"
	doors.find_child(current_subsector).toggle_door()
	
	# Prevent the door allowing access to the cleared room from being reopened when entering Officer1
	open_officer1_doors.erase(&"Officer1a" if current_subsector == &"Officer0" else &"Officer1b")
	
	# Update the status of each terminal on the Officer
	update_officer_terminal(
			subsector_terminal_data.Officer0.is_terminal_online,
			subsector_terminal_data.Officer2.is_terminal_online
	)


func officer_terminal_interact() -> void:
	# Initial interaction, start the officer sequence
	if is_officer_interaction_initial:
		main_script.toggle_timer(true, 60, Color.RED, func(): main_script.player.death(true))
		main_script.toggle_mirage_shader(true)
		open_officer1_doors.Officer1a.toggle_door(true)
		open_officer1_doors.Officer1b.toggle_door(true)
		subsector_terminal_data.Officer1.is_terminal_online = true
		is_officer_active = true
		is_officer_interaction_initial = false
		update_officer_terminal()
	
	# If both terminals are online
	elif (
			subsector_terminal_data.Officer0.is_terminal_online
			and subsector_terminal_data.Officer2.is_terminal_online
			and is_officer_active
	):
		main_script.toggle_timer(false)
		main_script.toggle_mirage_shader(false)
		doors.find_child(&"Officer1c").toggle_door(true)
		is_officer_active = false
		update_officer_terminal(true, true, true)
		main_script.add_completed_sector()
	
	# Reopen the elevator entrance door
	elif not is_officer_active:
		doors.find_child(&"Officer1c").toggle_door(true)


func update_officer_terminal(terminal_0_online: bool = false, terminal_1_online: bool = false, meltdown_stop: bool = false) -> void:
	officer_base.set_officer_task(
			"Terminal 0: " + ("ONLINE" if terminal_0_online else "OFFLINE") + "\n"
			+ "Terminal 1: " + ("ONLINE" if terminal_1_online else "OFFLINE") + "\n"
			+ ("SYSTEMS STABLE" if meltdown_stop else "MELTDOWN IMMINENT")
	)


func signal_dash() -> void:
	# extend dash platforms
	for platform in subsector_platforms:
		platform.move(true)
	
	return_timer.start()
	launch_boost_timeframe.start()
	is_launch_active = true


func _on_return_timer_timeout() -> void:
	# return dash platforms to their initial position
	for platform in subsector_platforms:
		platform.move(false)


func _on_launch_boost_timeframe_timeout() -> void:
	is_launch_active = false
