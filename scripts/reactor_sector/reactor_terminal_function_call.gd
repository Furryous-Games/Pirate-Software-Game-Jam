extends Node2D

@onready var reactor: Node2D = $"../"
@onready var doors: Node2D = $"../Doors"


func reactivate_cooling() -> void:
	# Only emit the signal if the subsector terminal has not already been activated
	if not reactor.subsector_terminal_data[reactor.current_subsector].is_terminal_activated:
		reactor.reactivate_cooling()
		doors.find_child(reactor.current_subsector).open_door()
