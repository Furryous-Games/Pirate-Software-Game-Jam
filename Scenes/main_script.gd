extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Camera

@onready var timing_mechanism_tick_one: TileMapLayer = $"Tilemaps/Mechanism Tick 1"
@onready var timing_mechanism_tick_two: TileMapLayer = $"Tilemaps/Mechanism Tick 2"
@onready var timing_mechanism_tick_three: TileMapLayer = $"Tilemaps/Mechanism Tick 3"

@onready var timing_mechanism_platform: Node2D = $"Timing Mechanism Platforms"

var all_timing_mechanism_platforms

var curr_room = Vector2i(0, 0)
var curr_timing_mechanism_tick = -1

func _ready() -> void:
	all_timing_mechanism_platforms = [timing_mechanism_tick_one, timing_mechanism_tick_two, timing_mechanism_tick_three]
	pass


func _input(event: InputEvent) -> void:
	pass


func enable_platform_layer(platform_layer: TileMapLayer, enable: bool):
	platform_layer.visible = enable
	platform_layer.collision_enabled = enable


func _process(delta: float) -> void:
	# Player moves to the room to the left
	if camera.to_local(player.position).x < 0:
		curr_room.x -= 1
		
		camera.position.x -= get_viewport().get_visible_rect().size.x
		
		print("LEFT")
	
	# Player moves to the room to the right
	elif camera.to_local(player.position).x > get_viewport().get_visible_rect().size.x:
		curr_room.x += 1
		
		camera.position.x += get_viewport().get_visible_rect().size.x
		
		print("RIGHT")
	
	# Player moves to the room to the top
	if camera.to_local(player.position).y < 0:
		curr_room.y -= 1
		
		camera.position.y -= get_viewport().get_visible_rect().size.y
		
		print("TOP")
	
	# Player moves to the room to the bottom
	elif camera.to_local(player.position).y > get_viewport().get_visible_rect().size.y:
		curr_room.y += 1
		
		camera.position.y += get_viewport().get_visible_rect().size.y
		
		print("BOTTOM")


func _on_timing_mechanism_tick() -> void:
	# Tick the current mechanism frame
	curr_timing_mechanism_tick = (curr_timing_mechanism_tick + 1) % len(all_timing_mechanism_platforms)
	
	# Hide all platforms
	for platform in all_timing_mechanism_platforms:
		enable_platform_layer(platform, false)
	
	# Enable the current platform frame
	enable_platform_layer(all_timing_mechanism_platforms[curr_timing_mechanism_tick], true)
	
	# Tick all timing mechanism platforms
	for timing_platform in timing_mechanism_platform.get_children():
		timing_platform._on_timing_mechanism_tick()
