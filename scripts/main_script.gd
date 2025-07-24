extends Node2D

## CAUTION: The TUTORIAL and ADMINISTRATIVE sectors have their code written, but are disabled as they do not yet actually exist

enum Sector {
	#TUTORIAL,
	ENGINEERING,
	LIFE_SUPPORT,
	LOGISTICS,
	#ADMINISTRATIVE,
}
@export var current_sector: Sector

#const TUTORIAL_SECTOR = preload("res://scenes/tutorial_sector.tscn")
const ENGINEERING_SECTOR = preload("res://scenes/engineering_sector.tscn")
const LIFE_SUPPORT_SECTOR = preload("res://scenes/life_support_sector.tscn")
const LOGISTICS_SECTOR = preload("res://scenes/logistics_sector.tscn")
#const ADMINISTRATIVE_SECTOR = preload("res://scenes/administrative_sector.tscn")

const SECTOR_DATA := {
	#Sector.TUTORIAL: {"player_position": Vector2i(0, 0),},
	Sector.ENGINEERING: {"player_position": Vector2i(100, 139),},
	Sector.LIFE_SUPPORT: {"player_position": Vector2i(300, 300),},
	Sector.LOGISTICS: {"player_position": Vector2i(300, 300),},
	#Sector.ADMINISTRATIVE: {"player_position": Vector2i(0, 0),},
}
# INFO: {"sector_map_offset": Vector2i(0, 0)} may be used to offset the sector's position to stand after the transition room betwixt it and the sector lobby

var current_room = Vector2i(0, 0)

@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Camera
@onready var sector_maps: Node2D = $SectorMaps


func _ready() -> void:
	load_sector(current_sector) 
	
	
func load_sector(get_sector: Sector) -> void:
	# unload other sectors
	if sector_maps.get_child_count() > 1:
		sector_maps.get_child(-1).free()
	
	# Load sector and add it to scene tree as child of SectorMaps
	var sector: Node2D
	match get_sector:
		#Sector.TUTORIAL: load_sector = TUTORIA_SECTOR.instantiate()
		Sector.ENGINEERING: sector = ENGINEERING_SECTOR.instantiate()
		Sector.LIFE_SUPPORT: sector = LIFE_SUPPORT_SECTOR.instantiate()
		Sector.LOGISTICS: sector = LOGISTICS_SECTOR.instantiate()
		#Sector.ADMINISTRATIVE: load_sector = ADMINISTRATIVE_SECTOR.instantiate()
	sector_maps.add_child(sector)
	current_sector = get_sector
	
	player.position = SECTOR_DATA[get_sector].player_position


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
