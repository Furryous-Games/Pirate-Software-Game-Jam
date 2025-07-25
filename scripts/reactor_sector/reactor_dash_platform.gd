extends AnimatableBody2D

@export var platform_data := {"size": Vector2.ONE, "velocity_magnitude": Vector2.ZERO, "velocity_direction": Vector2.ZERO}
@export var platform_atlas_tile := Vector2i(8, 3)

const TILE_SIZE: int = 20


var platform_positions := {"initial": Vector2.ZERO, "final": Vector2.ZERO}
var tween_position: Tween

@onready var platform_sprite: TileMapLayer = $PlatformSprite
@onready var platform_collider: CollisionShape2D = $PlatformCollider


func _ready() -> void:
	# Set initial and final positions
	platform_positions.initial = (position / TILE_SIZE) as Vector2
	platform_positions.final = platform_positions.initial + (platform_data.velocity_magnitude * platform_data.velocity_direction as Vector2)
	
	set_size(platform_data.size)
	
	
func set_size(get_size: Vector2i) -> void:
	for x in get_size.x:
		for y in get_size.y:
			platform_sprite.set_cell(Vector2i(x, y), 1, platform_atlas_tile)
	
	platform_collider.shape.size = get_size * TILE_SIZE
	platform_collider.position = (get_size - Vector2i.ONE) * 10


func move(to_final: bool) -> void:
	# override (cancel) active tweens
	if tween_position and tween_position.is_running():
		tween_position.kill()
	
	if to_final: # move to final position
		tween_position = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
		tween_position.tween_property(self, "position", (platform_positions.final * TILE_SIZE) as Vector2, 0.2)
	else: # move to initial position
		tween_position = create_tween()
		tween_position.tween_property(self, "position", (platform_positions.initial * TILE_SIZE) as Vector2, 2)
