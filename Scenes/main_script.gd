extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Camera

@onready var green_light_platforms: TileMapLayer = $"Tilemaps/Green Light Platforms"
@onready var blue_light_platforms: TileMapLayer = $"Tilemaps/Blue Light Platforms"
@onready var red_light_platforms: TileMapLayer = $"Tilemaps/Red Light Platforms"

var curr_room = Vector2i(0, 0)

func _ready() -> void:
	pass


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("green_light_change"):
		print("CHANGING TO GREEN LIGHT")
		enable_platform_layer(green_light_platforms, false)
		enable_platform_layer(blue_light_platforms, true)
		enable_platform_layer(red_light_platforms, true)
		
	elif Input.is_action_just_pressed("blue_light_change"):
		print("CHANGING TO BLUE LIGHT")
		enable_platform_layer(green_light_platforms, true)
		enable_platform_layer(blue_light_platforms, false)
		enable_platform_layer(red_light_platforms, true)
		
	elif Input.is_action_just_pressed("red_light_change"):
		print("CHANGING TO RED LIGHT")
		enable_platform_layer(green_light_platforms, true)
		enable_platform_layer(blue_light_platforms, true)
		enable_platform_layer(red_light_platforms, false)
		
	pass


func enable_platform_layer(platform_layer: TileMapLayer, enable: bool):
	platform_layer.visible = enable
	platform_layer.collision_enabled = enable


func _process(delta: float) -> void:
	if camera.to_local(player.position).x < 0:
		curr_room.x -= 1
		
		camera.position.x -= get_viewport().get_visible_rect().size.x
		
		print("LEFT")
		
	elif camera.to_local(player.position).x > get_viewport().get_visible_rect().size.x:
		curr_room.x += 1
		
		camera.position.x += get_viewport().get_visible_rect().size.x
		
		print("RIGHT")
