extends Node2D

@export var sector_main: Node2D

@onready var timed_gravity_flip: Timer = $"../Timed Gravity Flip"


## TIMER TOGGLING FUNCTIONS
func _enable_timer(initial_value: int, function_on_timeout = null):
	sector_main.main_script.toggle_timer(true, initial_value, Color.WHITE, function_on_timeout)

func _disable_timer():
	sector_main.main_script.toggle_timer(false)

## TUTORIAL
func t_dash() -> void:
	sector_main.timed_dash_action.wait_time = 10
	sector_main.timed_dash_action.start()

func _gravity_flip(wait_time: int = 10) -> void:
	# Flip the gravity if the timer is disabled
	if timed_gravity_flip.is_stopped():
		sector_main.main_script.player.gravity_invert()
	
	# Set the new wait time
	timed_gravity_flip.wait_time = wait_time
	
	# Restart the timer
	timed_gravity_flip.start()

func _gravity_flip_timeout() -> void:
	print("FLIP BACK")
	if sector_main.main_script.player.gravity_change == -1:
		# Flip the gravity back
		sector_main.main_script.player.gravity_invert()
	
	# Restart the timer
	timed_gravity_flip.stop()
	

## P1
func _start_p1_timer():
	_enable_timer(60, _p1_timer_timeout)
	sector_main.timed_dash_action.wait_time = 60
	sector_main.timed_dash_action.start()

func _p1_timer_timeout():
	print("TIMEOUT")
	sector_main.timed_dash_action.stop()
	
func _p1_exit():
	get_node("../Doors/P1 Exit door").timed_toggle(15, true)
