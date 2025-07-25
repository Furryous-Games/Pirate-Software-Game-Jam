extends AnimatableBody2D

@export var door_atlas_tile := Vector2i(14, 3)

const TILE_SIZE: int = 20
const DOOR_SIZE: int = 4

var tween_door: Tween

@onready var door_sprite: TileMapLayer = $DoorSprite
@onready var door_collider: CollisionShape2D = $DoorCollider


func _ready() -> void:
	set_size()


func set_size() -> void:
	for y in DOOR_SIZE:
		door_sprite.set_cell(Vector2i(0, y), 1, door_atlas_tile)
	
	door_collider.shape.size.y = DOOR_SIZE * TILE_SIZE
	door_collider.position.y = (DOOR_SIZE - 1) * 10


func open_door():
	tween_door = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween_door.tween_property(self, "position:y", position.y - (DOOR_SIZE * TILE_SIZE), 2)
