extends Node2D

enum Sector {
	TUTORIAL,
	GRAVITY,
	LOGISTICS,
	ENGINEERING,
	ADMINISTRATIVE,
}
@export var active_sector: Sector

var current_room = Vector2i(0, 0)

@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Camera


func _process(_delta: float) -> void:
	if camera.to_local(player.position).x < 0:
		current_room.x -= 1
		
		camera.position.x -= get_viewport().get_visible_rect().size.x
		
	elif camera.to_local(player.position).x > get_viewport().get_visible_rect().size.x:
		current_room.x += 1
		
		camera.position.x += get_viewport().get_visible_rect().size.x
