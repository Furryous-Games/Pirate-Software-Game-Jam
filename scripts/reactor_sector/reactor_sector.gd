extends Node2D

signal recharge_dash

const ROOM_SPAWN_DATA := {
	Vector2i(0, 0): Vector2i(300, 300), # Main
	Vector2i(-1, 0): Vector2i(-60, 300), # Tutorial 1
	Vector2i(-1,-1): Vector2i(-60, -25), # Tutorial 2
	Vector2i(-2, -1): Vector2i(-620, -40), # Puzzle 1a
	Vector2i(-3, -1): Vector2i(-1190, -225), # Puzzle 1b
	Vector2i(-3, -2): Vector2i(-1620, -385), # Puzzle 2a
	Vector2i(-2, -2): Vector2i(-1620, -385), # Puzzle 2b
	Vector2i(-1, -2): Vector2i(-1620, -385), # Puzzle 2c
	Vector2i(-1, -3): Vector2i(-300, -725), # Puzzle 2d, Pre-Boss
	Vector2i(0, -3): Vector2i(-1190, -225), # Boss 0,0
}

const ROOM_SECTION_DATA := {
	Vector2i(0, 0): {"section": "Main", "mechanisms": -1, "spawn_point": Vector2i(300, 300)}, # Main
	Vector2i(-1, 0): {"section": "Tutorial", "mechanisms": 0, "spawn_point": Vector2i(300, 300)}, # Tutorial
	Vector2i(-1,-1): {"section": "Tutorial", "mechanisms": -1, "spawn_point": Vector2i(300, 300)}, # Tutorial
	Vector2i(-2, -1): {"section": "Puzzle1", "mechanisms": 1, "spawn_point": Vector2i(-550, -40)}, # Puzzle 1
	Vector2i(-3, -1): {"section": "Puzzle1", "mechanisms": 1, "spawn_point": Vector2i(-550, -40)}, # Puzzle 1
	
	Vector2i(-3, -2): {"section": "Puzzle2", "mechanisms": 2, "spawn_point": Vector2i(-1620, -385)}, # Puzzle 2
	Vector2i(-2, -2): {"section": "Puzzle2", "mechanisms": 2, "spawn_point": Vector2i(-1620, -385)}, # Puzzle 2
	Vector2i(-1, -2): {"section": "Puzzle2", "mechanisms": 2, "spawn_point": Vector2i(-1620, -385)}, # Puzzle 2
	Vector2i(-1, -3): {"section": "Puzzle2", "mechanisms": 2, "spawn_point": Vector2i(-300, -725)}, # Puzzle 2
	Vector2i(0, -3): {"section": "Boss", "mechanisms": 3, "spawn_point": Vector2i(-550, -40)}, # Boss
}
var current_section_data: Dictionary
var active_section_mechanisms: int

var is_section_overheating = {
	"Main": true,
	"Tutorial": true,
	"Puzzle1": true,
	"Puzzle2": true,
	"Boss": true,
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


func signal_dash() -> void:
	# mechanisms: -1 have no mechanisms 
	if ROOM_SECTION_DATA[main_script.current_room].mechanisms == -1:
		return
	
	# get current room to activate their dash platforms
	active_section_mechanisms = current_section_data.mechanisms
	# extend dash platforms
	for platform in dash_platforms.get_child(active_section_mechanisms).get_children():
		platform.move(true)
	return_timer.start()


func get_new_room_data() -> void:
	# Gets the data for the room (section, mechanisms, sector spawn point)
	# BUG: Invalid access to property or key '(0, -1)' on a base object of type 'Dictionary' On timeout at (-1, -1)
	current_section_data = ROOM_SECTION_DATA[main_script.current_room]
	reset_room()
	
	# Turn on/off the minute timer and mirage when entering a room
	if is_section_overheating[current_section_data.section] != main_script.is_timer_active:
		main_script.toggle_timer(int(is_section_overheating[current_section_data.section]), 60, Color.WHITE, main_script.reactor_timer_timout)
		main_script.toggle_mirage_shader(int(is_section_overheating[current_section_data.section]))


func dash_recharge_entered() -> void:
	recharge_dash.emit()


func reactivate_cooling() -> void:
	is_section_overheating[current_section_data.section] = false
	main_script.toggle_timer(false)
	main_script.toggle_mirage_shader(false)


func reset_room() -> void:
	return_timer.stop()
	for platform in dash_platforms.get_child(active_section_mechanisms).get_children():
		platform.reset()


func _on_return_timer_timeout() -> void:
	# return dash platforms to their initial position
	for platform in dash_platforms.get_child(active_section_mechanisms).get_children():
		platform.move(false)
