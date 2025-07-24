extends AnimatableBody2D

@export var platform_data := {"size": Vector2i.ZERO, "velocity_magnitude": Vector2i.ZERO, "velocity_direction": Vector2i.ZERO}

const TILE_SIZE = 20

var platform_positions := {"initial": Vector2i.ZERO, "final": Vector2i.ZERO}
var tween_position: Tween

@onready var platform_sprite: TileMapLayer = $PlatformSprite
@onready var platform_collider: CollisionShape2D = $PlatformCollider


func _ready() -> void:
	platform_positions.initial = position as Vector2i
	platform_positions.final = platform_positions.initial + platform_data.velocity_magnitude * platform_data.velocity_direction
	
	set_size(platform_data.size)
	
	
func set_size(get_size: Vector2i) -> void:
	for x in get_size.x:
		for y in get_size.y:
			platform_sprite.set_cell(Vector2i(x, y), 1, Vector2i(8, 3))
	
	platform_collider.shape.size = get_size * 20
	platform_collider.position = (get_size - Vector2i.ONE) * 10


func move(to_final: bool) -> void:
	match to_final:
		true: # move to final position
			tween_position = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
			tween_position.tween_property(self, "position", (platform_positions.final * TILE_SIZE) as Vector2, 0.2)
		false: # move to initial position
			tween_position = create_tween()
			tween_position.tween_property(self, "position", (platform_positions.initial * TILE_SIZE) as Vector2, 3)
	
