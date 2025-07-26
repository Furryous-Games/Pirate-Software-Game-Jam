extends Node2D

@onready var reactor: Node2D = $"../"
@onready var doors: Node2D = $"../Doors"


func reactivate_cooling() -> void:
	# Only emit the signal if the section if overheating (only interact with each terminal once)
	if reactor.is_section_overheating[reactor.current_section_data.section]:
		reactor.reactivate_cooling()
		doors.find_child(reactor.current_section_data.section).open_door()
