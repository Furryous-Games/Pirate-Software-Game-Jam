extends Node2D

## CAUTION: The TUTORIAL and ADMINISTRATIVE sectors have their code written, but are disabled as they do not yet actually exist

enum Sector {
	#TUTORIAL,
	ENGINEERING,
	LIFE_SUPPORT,
	REACTOR,
	#ADMINISTRATIVE,
}
@export var current_sector: Sector

#const TUTORIAL_SECTOR = preload("res://scenes/tutorial_sector.tscn")
const ENGINEERING_SECTOR = preload("res://scenes/engineering_sector.tscn")
const LIFE_SUPPORT_SECTOR = preload("res://scenes/life_support_sector.tscn")
const REACTOR_SECTOR = preload("res://scenes/reactor_sector.tscn")
#const ADMINISTRATIVE_SECTOR = preload("res://scenes/administrative_sector.tscn")

const SECTOR_DATA := {
	#Sector.TUTORIAL: {"player_position": Vector2i(0, 0),},
	Sector.ENGINEERING: {"player_position": Vector2i(2700, 280),}, # 100, 139
	Sector.LIFE_SUPPORT: {"player_position": Vector2i(2340,140),},
	Sector.REACTOR: {"player_position": Vector2i(300, 300),},
	#Sector.ADMINISTRATIVE: {"player_position": Vector2i(0, 0),},
}
# INFO: {"sector_map_offset": Vector2i(0, 0)} may be used to offset the sector's position to stand after the transition room betwixt it and the sector lobby

var current_room = Vector2i(0, 0)
var is_timer_active := false
var tween_mirage: Tween
var is_mirage_shader_active := false

var room_spawn: Dictionary

@onready var sector_maps: Node2D = $SectorMaps
@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Camera

@onready var minute_bar: ProgressBar = $UI/MinuteBar
@onready var minute_display: Label = $UI/MinuteDisplay
@onready var minute_timer: Timer = $UI/MinuteTimer
@onready var minute_bar_bg_color: StyleBoxFlat = minute_bar.get_theme_stylebox("fill")

@onready var mirage: ColorRect = $ScreenShaders/Mirage



func _ready() -> void:
	load_sector(current_sector)


func load_sector(get_sector: Sector) -> void:
	# unload other sectors
	if sector_maps.get_child_count() > 1:
		sector_maps.get_child(-1).free()
	
	# Load sector and add it to scene tree as child of SectorMaps
	var sector: Node2D
	match get_sector:
		#Sector.TUTORIAL: 
			#load_sector = TUTORIA_SECTOR.instantiate()
		Sector.ENGINEERING: 
			sector = ENGINEERING_SECTOR.instantiate()
		Sector.LIFE_SUPPORT: 
			sector = LIFE_SUPPORT_SECTOR.instantiate()
		Sector.REACTOR: 
			sector = REACTOR_SECTOR.instantiate()
			toggle_mirage_shader()
			toggle_timer(true, 60, Color.RED, reactor_timer_timout)
		#Sector.ADMINISTRATIVE: 
			#load_sector = ADMINISTRATIVE_SECTOR.instantiate()
	
	# Add sector scene as child of SectorMaps
	sector_maps.add_child(sector)
	current_sector = get_sector
	
	# Set room spawn data
	room_spawn = sector_maps.get_child(-1).ROOM_SPAWN_DATA
	player.set_room_spawn(room_spawn)
	
	# Spawn player at designated position
	player.position = SECTOR_DATA[get_sector].player_position


func toggle_mirage_shader() -> void:
	is_mirage_shader_active = not is_mirage_shader_active
	tween_mirage = create_tween()
	tween_mirage.tween_property(mirage, "material:shader_parameter/is_active", int(is_mirage_shader_active), 10)


func toggle_timer(on: bool, set_time: int = 60, set_color: Color = Color.RED, on_timeout = null) -> void:
	if on:
		# Set the color for the timer
		change_timer_color(set_color)
		
		# Set the time for the timer and bar
		minute_timer.wait_time = set_time
		minute_bar.max_value = set_time
		
		# Remove all current connections for timeout on the timer
		for connection in minute_timer.get_signal_connection_list("timeout"):
			connection.signal.disconnect(connection.callable)
		
		# Set the function connection to the timer
		if on_timeout != null:
			minute_timer.connect("timeout", on_timeout)
		
		# TODO: Connect the timeout for the minute timer to disable the timer
		
		# Start the timer
		minute_timer.start()
		is_timer_active = true
			
	else:
		minute_display.text = "--.--"
		change_timer_color(Color.AQUA)
		# refill the bar
		var tween_minute_bar: Tween = create_tween()
		tween_minute_bar.tween_property(minute_bar, "value", 60, 0.4)
		is_timer_active = false


func change_timer_color(new_color: Color) -> void:
	minute_display.label_settings.font_color = new_color
	minute_bar_bg_color.bg_color = new_color


func reactor_timer_timout() -> void:
	player.death()
	toggle_timer(true, 60, Color.RED, reactor_timer_timout)


func _process(_delta: float) -> void:
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
	
	# Updates the timer display
	if is_timer_active:
		var time_left: float = snappedf(minute_timer.time_left, 0.01)
		minute_display.text = ("0" if time_left < 10.00 else "") + str(time_left)
		minute_bar.value = time_left
