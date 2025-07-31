extends Node

@onready var main_script = $"../../"

@export var portal_node: Node2D

func get_room_spawn_position(_room: Vector2i = Vector2i.ZERO) -> Vector2i:
	return Vector2i(280, 320)

func _ready() -> void:
	
	if main_script.check_compleated_sector():
		get_node("Portals/Portal").unlock_portal()
