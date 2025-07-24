extends Node2D

signal dash_recharge

const ROOM_SPAWN_DATA := {
	Vector2i(0, 0): Vector2i(300, 300), # Main
	Vector2i(-1, 0): Vector2i(300,300), # Tutorial 1a
	Vector2i(-1,-1): Vector2i(300, 300), # Tutorial 1b
	Vector2i(-2, -1): Vector2i(300, 300), # Tutorial 2a
	Vector2i(-3, -1): Vector2i(300, 300), # Tutorial 2b
}

const ROOM_DATA := {
	Vector2i(0, 0): 0, # Main
	Vector2i(-1, 0): 0, # Tutorial 1a
	Vector2i(-1,-1): 0, # Tutorial 1b
	Vector2i(-2, -1): 1, # Tutorial 2a
	Vector2i(-3, -1): 1, # Tutorial 2b
}
var current_room_from_data: int

var is_room_overheating = {
	"Tutorial_1": true,
	"Tutorial_2": true,
	"Puzzle_1": true,
	"Puzzle_2": true,
	"Boss": true,
}

@onready var main_script: Node2D = $"../../"
@onready var dash_platforms: Node2D = $DashPlatforms
@onready var return_timer: Timer = $ReturnTimer


func _ready() -> void:
	# connects to signal emitted from player dash 
	main_script.player.player_dash.connect(func(): signal_dash())
	# connects dash_recharge signal to player
	self.dash_recharge.connect(main_script.player.recharge_dash)


func signal_dash() -> void:
	# If room is (0,0) do nothing
	if main_script.current_room == Vector2i.ZERO:
		return
	
	# get current room to activate their dash platforms
	current_room_from_data = ROOM_DATA[main_script.current_room]
	# extend dash platforms
	for platform in dash_platforms.get_child(current_room_from_data).get_children():
		platform.move(true)
	return_timer.start()


func dash_recharge_entered() -> void:
	print("dash recharge signal received")
	dash_recharge.emit()


func _on_return_timer_timeout() -> void:
	# return dash platforms to their initial position
	for platform in dash_platforms.get_child(current_room_from_data).get_children():
		platform.move(false)
