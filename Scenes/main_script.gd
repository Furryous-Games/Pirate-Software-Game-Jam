extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Camera

var curr_room = Vector2i(0, 0)

func _ready() -> void:
	pass


func _input(event: InputEvent) -> void:
	pass


func _process(delta: float) -> void:
	# Player moves to the room to the left
	if camera.to_local(player.position).x < 0:
		curr_room.x -= 1
		
		camera.position.x -= get_viewport().get_visible_rect().size.x
	
	# Player moves to the room to the right
	elif camera.to_local(player.position).x > get_viewport().get_visible_rect().size.x:
		curr_room.x += 1
		
		camera.position.x += get_viewport().get_visible_rect().size.x
	
	# Player moves to the room to the top
	if camera.to_local(player.position).y < 0:
		curr_room.y -= 1
		
		camera.position.y -= get_viewport().get_visible_rect().size.y
	
	# Player moves to the room to the bottom
	elif camera.to_local(player.position).y > get_viewport().get_visible_rect().size.y:
		curr_room.y += 1
		
		camera.position.y += get_viewport().get_visible_rect().size.y
