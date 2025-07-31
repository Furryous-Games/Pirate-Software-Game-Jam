extends AnimatableBody2D

@export var vertical_door: bool = true
@export var door_size = 4

const TILE_SIZE: int = 20
const DOOR_ATLAS_TILE = Vector2i(14, 3)

var tween_door: Tween
var is_door_closed := true

@onready var door_sprite: TileMapLayer = $DoorSprite
@onready var door_collider: CollisionShape2D = $DoorCollider
@onready var initial_position: Vector2 = position


func _ready() -> void:
	set_size()


func set_size() -> void:
	if vertical_door:
		for i in door_size:
			door_sprite.set_cell(Vector2i(0, i), 0, DOOR_ATLAS_TILE)
		door_collider.shape.size.y = door_size * TILE_SIZE
		door_collider.position.y = (door_size - 1) * 10
	else:
		for i in door_size:
			door_sprite.set_cell(Vector2i(i, 0), 1, DOOR_ATLAS_TILE)
		door_collider.shape.size.x = door_size * TILE_SIZE
		door_collider.position.x = (door_size - 1) * 10


func toggle_door(open: bool = true) -> void:
	if open == not is_door_closed:
		return
	
	var new_position: Vector2 = initial_position
	if vertical_door:
		new_position.y += TILE_SIZE * door_size * -(int(is_door_closed))
	else: 
		new_position.x += TILE_SIZE * door_size * -(int(is_door_closed))
	
	is_door_closed = not is_door_closed
	
	tween_door = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUINT)
	tween_door.tween_property(self, "position", new_position, 1.5)
	
