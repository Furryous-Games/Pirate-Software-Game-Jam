extends AnimatableBody2D

@export var max_distance: Vector2i
@export var start_distance: Vector2i

@export var initial_direction: Vector2i = Vector2i(1, 1)
@export var step_size: int
@export var platform_size: Vector2i

@export var instant_return: bool

@onready var platform_sprite: TileMapLayer = $"Platform Visual"
@onready var platform_collider: CollisionShape2D = $"Platform Collider"


var original_position

var curr_distance = Vector2i(0, 0)
var curr_vertical_distance = 0
var curr_direction = Vector2i(1, 1)


func _ready() -> void:
	original_position = position
	
	# Set the directions to 0 if the platform doesnt move on the axis
	if max_distance.x == 0:
		curr_direction.x = 0
	if max_distance.y == 0:
		curr_direction.y = 0
	
	# Set the step size and initial direction
	curr_direction *= step_size
	curr_direction *= initial_direction
	
	# Expand the platform to its set size
	expand_platform(platform_size)
	
	# Move the position to its starting distance
	if start_distance != Vector2i(0, 0):
		warp_to_position(start_distance, 0)
	
	# If the platform is set to instant return, add padding to its max distances
	if instant_return:
		if max_distance.x < 0:
			max_distance.x -= step_size
		if max_distance.x > 0:
			max_distance.x += step_size
		if max_distance.y < 0:
			max_distance.y -= step_size
		if max_distance.y > 0:
			max_distance.y += step_size
		
		print(curr_distance)

func expand_platform(new_size: Vector2i) -> void:
	for x in range(new_size.x):
		for y in range(new_size.y):
			platform_sprite.set_cell(Vector2i(x, y), 1, Vector2i(14, 3))
	
	platform_collider.shape.size = new_size * 20
	platform_collider.position = (new_size - Vector2i.ONE) * 10


func warp_to_position(new_pos: Vector2i, time_to_move: float, disable_collider: bool = true) -> void:
	# Reset the sprite's distance
	curr_distance = new_pos
	
	# If disable collider is true, then move the platform with no collider
	if disable_collider:
		# Makes the mechanism temporarily not collide with anything
		platform_collider.disabled = true
		
		# Delays the reenabling of the collider
		get_tree().create_timer(time_to_move + 0.1).timeout.connect(enable_collider)
	
	# Move the sprite
	var tween = create_tween()
	tween.tween_property($".", "position", Vector2(original_position.x + (20 * curr_distance.x), original_position.y + (20 * curr_distance.y)), time_to_move)


func _on_timing_mechanism_tick() -> void:
	var move_platform = true
	
	# If the platform has hit either edge of its rail on the horizontal axis, then flip its direction
	if curr_distance.x + curr_direction.x < min(0, max_distance.x) or curr_distance.x + curr_direction.x > max(0, max_distance.x):
		# Handles instant return
		if instant_return and curr_distance.x != 0:
			# Warp the platform to the new position
			warp_to_position(Vector2i(0, curr_distance.y), 0)
			move_platform = false
		else:
			curr_direction.x *= -1
	
	# If the platform has hit either edge of its rail on the vertical axis, then flip its direction
	if curr_distance.y + curr_direction.y < min(0, max_distance.y) or curr_distance.y + curr_direction.y > max(0, max_distance.y):
		# Handles instant return
		if instant_return and curr_distance.y != 0:
			# Warp the platform to the new position
			warp_to_position(Vector2i(curr_distance.x, 0), 0)
			move_platform = false
		else:
			curr_direction.y *= -1
	
	# Move the sprite
	if move_platform:
		var tween = create_tween()
		tween.tween_property($".", "position", Vector2(original_position.x + (20 * curr_distance.x), original_position.y + (20 * curr_distance.y)), 0.15)
	
	# Update the current horizontal distance
	curr_distance += curr_direction
	
	# Enable the collider if disabled
	#if platform_collider.disabled:
		#platform_collider.disabled = false

func enable_collider() -> void:
	platform_collider.disabled = false
