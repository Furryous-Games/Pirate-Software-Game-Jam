extends AnimatableBody2D

@export_group(&"Platform Data")
@export var size := Vector2i.ONE ## platform dimentions
@export_range(0, 12) var magnitude: int = 1 ## Number of tiles moved [br]Range: (0, 12)
@export var direction := Vector2i.ZERO ## Movement direction [br]Range: (-1, 1)

const TILE_SIZE: int = 20
const ATLAS_TILE = Vector2i(8, 3)

var platform_positions := {&"initial": Vector2.ZERO, &"final": Vector2.ZERO}
var tween_position: Tween

@onready var reactor: Node2D = $"../../.."
@onready var platform_data = {&"size": size, &"magnitude": magnitude, &"direction": direction}
@onready var platform_sprite: TileMapLayer = $PlatformSprite
@onready var platform_collider: CollisionShape2D = $PlatformCollider


func _ready() -> void:
	# Set initial and final positions
	platform_positions.initial = position / TILE_SIZE
	platform_positions.final = platform_positions.initial + (platform_data.magnitude * platform_data.direction as Vector2)
	
	set_size(platform_data.size)
	
	
func set_size(get_size: Vector2i) -> void:
	for x in get_size.x:
		for y in get_size.y:
			platform_sprite.set_cell(Vector2i(x, y), 1, ATLAS_TILE)
	
	platform_collider.shape.size = get_size * TILE_SIZE
	platform_collider.position = (get_size - Vector2i.ONE) * 10


func move(to_final: bool, return_speed: float = 1.5) -> void:
	# override (cancel) active tweens
	if tween_position and tween_position.is_running():
		tween_position.kill()
	
	if to_final: # move to final position
		tween_position = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
		tween_position.tween_property(self, "position", platform_positions.final * TILE_SIZE, 0.2)
	else: # move to initial position
		tween_position = create_tween()
		tween_position.tween_property(self, "position", platform_positions.initial * TILE_SIZE, return_speed)
