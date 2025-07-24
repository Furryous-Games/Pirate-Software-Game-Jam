extends Node2D

var is_room_overheating = {
	"Tutorial_1": true,
	"Tutorial_2": true,
	"Puzzle_1": true,
	"Puzzle_2": true,
	"Boss": true,
}

var reactor_room: int = 0

@onready var main_script: Node2D = $"../../"
@onready var current_room: Vector2i = main_script.current_room
@onready var dash_platforms: Node2D = $DashPlatforms
@onready var return_timer: Timer = $ReturnTimer


func _ready() -> void:
	main_script.player.player_dash.connect(func(): signal_dash())


func signal_dash() -> void:
	#print(dash_platforms.get_child(reactor_room))
	for platform in dash_platforms.get_child(reactor_room).get_children():
		platform.move(true)
	return_timer.start()


func _on_return_timer_timeout() -> void:
	for platform in dash_platforms.get_child(reactor_room).get_children():
		platform.move(false)
