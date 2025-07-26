extends AnimatableBody2D

@export var vertical_door: bool = true
@export var door_atlas_tile := Vector2i(14, 3)

const TILE_SIZE: int = 20
const DOOR_SIZE: int = 4

var tween_door: Tween

@onready var door_sprite: TileMapLayer = $DoorSprite
@onready var door_collider: CollisionShape2D = $DoorCollider


func _ready() -> void:
	set_size()


func set_size() -> void:
	
	if vertical_door:
		for i in DOOR_SIZE:
			door_sprite.set_cell(Vector2i(0, i), 1, door_atlas_tile)
		door_collider.shape.size.y = DOOR_SIZE * TILE_SIZE
		door_collider.position.y = (DOOR_SIZE - 1) * 10
	else:
		for i in DOOR_SIZE:
			door_sprite.set_cell(Vector2i(i, 0), 1, door_atlas_tile)
		door_collider.shape.size.x = DOOR_SIZE * TILE_SIZE
		door_collider.position.x = (DOOR_SIZE - 1) * 10


func open_door() -> void:
	tween_door = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	if vertical_door:
		tween_door.tween_property(self, "position:y", position.y - (DOOR_SIZE * TILE_SIZE), 2)
	else:
		tween_door.tween_property(self, "position:x", position.x - (DOOR_SIZE * TILE_SIZE), 2)
