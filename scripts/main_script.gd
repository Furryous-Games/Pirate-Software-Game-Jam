extends Node2D

signal room_change

enum Sector {
	TUTORIAL,
	ATRIUM,
	ENGINEERING,
	LIFE_SUPPORT,
	REACTOR,
	ADMINISTRATIVE,
	ADMINISTRATIVE_OFFICER
}
@export var current_sector: Sector = Sector.TUTORIAL

const TUTORIAL_SECTOR = preload("res://scenes/tutorial_sector.tscn")
const ATRIUM = preload("res://scenes/atrium.tscn")
const ENGINEERING_SECTOR = preload("res://scenes/engineering_sector.tscn")
const LIFE_SUPPORT_SECTOR = preload("res://scenes/life_support_sector.tscn")
const REACTOR_SECTOR = preload("res://scenes/reactor_sector/reactor_sector.tscn")
const ADMINISTRATIVE_SECTOR = preload("res://scenes/administrative_sector.tscn")
const ADMINISTATIVE_SECTOR_OFFICER = preload("res://scenes/administrative_sector_officer.tscn")

const CAMERA_PAN_TIME = 0.3

var current_room = Vector2i(0, 0)
var completed_sectors: Array[Sector]

var is_timer_active := false
var is_mirage_shader_active := false
var tween_mirage: Tween
var mirage_lock := false

var is_smooth_camera_on := true
var camera_tween: Tween
var camera_pos: Vector2

@onready var sector_maps: Node2D = $SectorMaps
@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Camera

@onready var minute_bar: ProgressBar = $UI/MinuteBar
@onready var minute_display: Label = $UI/MinuteDisplay
@onready var minute_timer: Timer = $UI/MinuteTimer
@onready var minute_bar_bg_color: StyleBoxFlat = minute_bar.get_theme_stylebox("fill")

@onready var mirage: ColorRect = $ScreenShaders/Mirage
@onready var terminal_console: Panel = $Title/TerminalConsole


func _ready() -> void:

	terminal_console.output_intro()


func load_sector(get_sector: Sector) -> void:
	# unload other sectors
	if sector_maps.get_child_count() > 1:
		sector_maps.get_child(-1).free()
	
	# Load sector and add it to scene tree as child of SectorMaps
	var sector: Node2D
	match get_sector:
		Sector.TUTORIAL: 
			sector = TUTORIAL_SECTOR.instantiate()
			
		Sector.ATRIUM:
			sector = ATRIUM.instantiate()
			
		Sector.ENGINEERING: 
			sector = ENGINEERING_SECTOR.instantiate()
			
		Sector.LIFE_SUPPORT: 
			sector = LIFE_SUPPORT_SECTOR.instantiate()
			
		Sector.REACTOR: 
			sector = REACTOR_SECTOR.instantiate()
			toggle_timer(true, 60, Color.WHITE, func(): player.death(true))
			toggle_mirage_shader(true)
			
		Sector.ADMINISTRATIVE: 
			sector = ADMINISTRATIVE_SECTOR.instantiate()
		
		Sector.ADMINISTRATIVE_OFFICER:
			sector = ADMINISTATIVE_SECTOR_OFFICER.instantiate()
	
	# Add sector scene as child of SectorMaps
	sector_maps.add_child(sector) 
	
	current_sector = get_sector
	# Set player.sector to the sector Node2D, allowing direct access instead of using main_script.sector_maps.get_child(-1)
	player.sector = sector 
	
	if get_sector == Sector.REACTOR:
		sector.get_new_room_data()
	
	# Spawn player at designated position
	player.position = sector.get_room_spawn_position()


func toggle_mirage_shader(on: bool = true) -> void:
	if is_mirage_shader_active == on or mirage_lock:
		return
	
	is_mirage_shader_active = not is_mirage_shader_active
	tween_mirage = create_tween()
	tween_mirage.tween_property(mirage, "material:shader_parameter/is_active", int(is_mirage_shader_active), 5)


func toggle_timer(on: bool, set_time: int = 60, set_color: Color = Color.WHITE, on_timeout = null) -> void:
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
		
		# Start the timer
		minute_timer.start()
		is_timer_active = true
			
	else:
		minute_display.text = "--.--"
		change_timer_color(Color.WHITE)
		minute_timer.stop()
		# refill the bar
		var tween_minute_bar: Tween = create_tween()
		tween_minute_bar.tween_property(minute_bar, "value", 60, 0.4)
		is_timer_active = false


func change_timer_color(new_color: Color) -> void:
	minute_display.label_settings.font_color = new_color
	minute_bar_bg_color.bg_color = new_color


func check_completed_sectors(sector: Sector) -> bool:
	return completed_sectors.has(sector)


func add_completed_sector(sector: Sector = current_sector) -> void:
	if !check_completed_sectors(sector):
		completed_sectors.append(sector)


func check_compleated_sector() -> bool:
	return completed_sectors.size() >= 3


func _process(_delta: float) -> void:
	if is_smooth_camera_on :
		if camera_tween != null:
			return
		
		## Smooth Camera
		# Move camera, don't check if camera is currently moving
		camera_pos = camera.position
		
		# Finds the new location for the camera
		for i in 100:
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
		
		# A change has occured to the camera position
		if camera_pos != camera.position:
			var new_camera_pos = camera.position
			camera.position = camera_pos
			
			camera_tween = create_tween()
			
			# Move the camera
			camera_tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
			camera_tween.tween_property(camera, "position", new_camera_pos, CAMERA_PAN_TIME)
			camera_tween.finished.connect(func(): camera_tween = null)
			room_change.emit()
	
	else:
		## Original Camera
		if camera.to_local(player.position).x < 0:
			current_room.x -= 1
			camera.position.x -= get_viewport().get_visible_rect().size.x
			room_change.emit()
		 # Player moves to the room to the right
		elif camera.to_local(player.position).x > get_viewport().get_visible_rect().size.x:
			current_room.x += 1
			camera.position.x += get_viewport().get_visible_rect().size.x
			room_change.emit()
		 # Player moves to the room to the top
		if camera.to_local(player.position).y < 0:
			current_room.y -= 1
			camera.position.y -= get_viewport().get_visible_rect().size.y
			room_change.emit()
		 # Player moves to the room to the bottom
		elif camera.to_local(player.position).y > get_viewport().get_visible_rect().size.y:
			current_room.y += 1
			camera.position.y += get_viewport().get_visible_rect().size.y
			room_change.emit()
	
	# Updates the timer display
	if is_timer_active:
		var time_left: float = snappedf(minute_timer.time_left, 0.01)
		minute_display.text = ("0" if time_left < 10.00 else "") + str(time_left)
		minute_bar.value = time_left
