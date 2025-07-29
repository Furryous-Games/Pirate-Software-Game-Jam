extends Node2D

@onready var reactor: Node2D = $".."

var is_interaction_initial := true


func officer_interacted() -> void:
	# Initial interaction
	if is_interaction_initial:
		reactor.main_script.toggle_timer(true, 60, Color.RED, officer_timeout)
		reactor.main_script.toggle_mirage_shader(true)
		reactor.officer_room_data.doors.Officer1[0].toggle_door(true)
		reactor.officer_room_data.doors.Officer1[1].toggle_door(true)
		reactor.officer_room_data.is_terminal_activated.Officer1 = true
		reactor.is_officer_active = true
		is_interaction_initial = false
	
	else:
		reactor.main_script.toggle_timer(false)
		reactor.main_script.toggle_mirage_shader(false)
		reactor.officer_room_data.doors.OfficerEnd.toggle_door(true)
		reactor.is_officer_active = false
		

func officer_timeout() -> void:
	reactor.main_script.player.death()
