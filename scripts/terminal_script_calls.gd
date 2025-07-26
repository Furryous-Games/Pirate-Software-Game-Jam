extends Node2D

@export var sector_main: Node2D


## TIMER TOGGLING FUNCTIONS
func _enable_timer(initial_value: int, function_on_timeout = null):
	sector_main.main_script.toggle_timer(true, initial_value, Color.WHITE, function_on_timeout)

func _disable_timer():
	sector_main.main_script.toggle_timer(false)
	

## T1 ROOM
func tutorial_one_exit() -> void:
	# Disable the timer
	_disable_timer()
	
	# Make the door single interact (wont close)
	get_node("../Doors/Engineering T1/Exit Door").single_interact = true
	
	# Enable the door
	get_node("../Doors/Engineering T1/Exit Door").toggle_door(true)

## T2 ROOM
func tutorial_two_exit() -> void:
	# Disable the timer
	_disable_timer()
	
	# Make the door single interact (wont close)
	get_node("../Doors/Engineering T2/Exit Door").single_interact = true
	
	# Enable the door
	get_node("../Doors/Engineering T2/Exit Door").toggle_door(true)

## P1 ROOM
func puzzle_one_terminal() -> void:
	# Set a timer
	_enable_timer(60, puzzle_one_reset)
	
	# Enable the door
	get_node("../Doors/Engineering P1/Puzzle Door").toggle_door(true)
func puzzle_one_reset() -> void:
	# Disable the door
	get_node("../Doors/Engineering P1/Puzzle Door").toggle_door(false)

func puzzle_one_exit() -> void:
	# Disable the timer
	_disable_timer()
	
	# Make the door single interact (wont close)
	get_node("../Doors/Engineering P1/Puzzle Door").single_interact = true
	get_node("../Doors/Engineering P1/Exit Door").single_interact = true
	
	# Enable the door
	get_node("../Doors/Engineering P1/Puzzle Door").toggle_door(true)
	get_node("../Doors/Engineering P1/Exit Door").toggle_door(true)

## P2 ROOM
func puzzle_two_a_terminal() -> void:
	# Set a timer
	_enable_timer(60, puzzle_two_a_reset)
	
	# Enable the door
	get_node("../Doors/Engineering P2/Puzzle Door").toggle_door(true)
func puzzle_two_a_reset() -> void:
	# Disable the door
	get_node("../Doors/Engineering P2/Puzzle Door").toggle_door(false)

func puzzle_two_b_terminal() -> void:
	# Toggle the door for a set time
	get_node("../Doors/Engineering P2/Bridge Door A").timed_toggle(10, true)
	get_node("../Doors/Engineering P2/Bridge Door B").timed_toggle(10, true)
func puzzle_two_b_reset() -> void:
	pass

func puzzle_two_exit() -> void:
	# Disable the timer
	_disable_timer()
	
	# Make the door single interact (wont close)
	get_node("../Doors/Engineering P2/Puzzle Door").single_interact = true
	get_node("../Doors/Engineering P2/Exit Door").single_interact = true
	
	# Enable the door
	get_node("../Doors/Engineering P2/Puzzle Door").toggle_door(true)
	get_node("../Doors/Engineering P2/Exit Door").toggle_door(true)


func _test_terminal() -> void:
	get_node("../Doors/TESTING/Door").toggle_door()
	get_node("../Doors/TESTING/Door 2").toggle_door()
	get_node("../Doors/TESTING/Door 3").toggle_door()
	get_node("../Doors/TESTING/Door 4").toggle_door()
