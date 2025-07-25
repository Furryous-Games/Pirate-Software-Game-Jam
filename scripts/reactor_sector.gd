extends Node2D

signal recharge_dash

const ROOM_SPAWN_DATA := {
	Vector2i(0, 0): Vector2i(300, 300), # Main
	Vector2i(-1, 0): Vector2i(-60, 300), # Tutorial 1
	Vector2i(-1,-1): Vector2i(-60, 20), # Tutorial 2
	Vector2i(-2, -1): Vector2i(-600, -230), # Puzzle 1a
	Vector2i(-3, -1): Vector2i(-600, -230), # Puzzle 1b
}

const ROOM_SECTION_DATA := {
	Vector2i(0, 0): {"title": "Main", "mechanisms": 0, "spawn_point": Vector2i(300, 300)},
	Vector2i(-1, 0): {"title": "Tutorial1", "mechanisms": 0, "spawn_point": Vector2i(300, 300)},
	Vector2i(-1,-1): {"title": "Tutorial2", "mechanisms": 0, "spawn_point": Vector2i(300, 300)},
	Vector2i(-2, -1): {"title": "Puzzle1", "mechanisms": 1, "spawn_point": Vector2i(-600, -230)},
	Vector2i(-3, -1): {"title": "Puzzle1", "mechanisms": 1, "spawn_point": Vector2i(-600, -230)},
}
var current_section_data: Dictionary
var active_section_mechanisms: int

var is_section_overheating = {
	"Main": true,
	"Tutorial1": true,
	"Tutorial2": true,
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
	# If room is (0,0) do nothing
	if main_script.current_room == Vector2i.ZERO:
		return
	
	# get current room to activate their dash platforms
	active_section_mechanisms = current_section_data.mechanisms
	#print(current_section)
	#print(dash_platforms.get_child(current_section))
	# extend dash platforms
	for platform in dash_platforms.get_child(active_section_mechanisms).get_children():
		platform.move(true)
	return_timer.start()


func get_new_room_data():
	current_section_data = ROOM_SECTION_DATA[main_script.current_room]
	
	if is_section_overheating[current_section_data.title] != main_script.is_timer_active:
		main_script.toggle_timer(int(is_section_overheating[current_section_data.title]))
		main_script.toggle_mirage_shader()


func dash_recharge_entered() -> void:
	recharge_dash.emit()


func reactivate_cooling() -> void:
	is_section_overheating[current_section_data.title] = false
	main_script.toggle_timer(false)
	main_script.toggle_mirage_shader()


func _on_return_timer_timeout() -> void:
	# return dash platforms to their initial position
	for platform in dash_platforms.get_child(active_section_mechanisms).get_children():
		platform.move(false)
