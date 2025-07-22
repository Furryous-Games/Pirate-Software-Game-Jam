extends Node2D

enum Sector {
	TUTORIAL,
	LIFE_SUPPORT,
	LOGISTICS,
	ENGINEERING,
	ADMINISTRATIVE,
}
@export var current_sector: Sector

var current_room = Vector2i(0, 0)

@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Camera


func _process(delta: float) -> void:
	# Player moves to the room to the left
	if camera.to_local(player.position).x < 0:
		current_room.x -= 1
		
		camera.position.x -= get_viewport().get_visible_rect().size.x
	
	# Player moves to the room to the right
	elif camera.to_local(player.position).x > get_viewport().get_visible_rect().size.x:
		current_room.x += 1
		
		camera.position.x += get_viewport().get_visible_rect().size.x
	
	# Player moves to the room to the top
	if camera.to_local(player.position).y < 0:
		current_room.y -= 1
		
		camera.position.y -= get_viewport().get_visible_rect().size.y
	
	# Player moves to the room to the bottom
	elif camera.to_local(player.position).y > get_viewport().get_visible_rect().size.y:
		current_room.y += 1
		
		camera.position.y += get_viewport().get_visible_rect().size.y
