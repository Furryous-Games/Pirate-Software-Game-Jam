extends AnimatableBody2D

@export var max_distance: Vector2i

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


func _on_timing_mechanism_tick() -> void:
	# If the platform has hit either edge of its rail on the horizontal axis, then flip its direction
	if curr_distance.x + curr_direction.x < min(0, max_distance.x + 1) or curr_distance.x + curr_direction.x > max(0, max_distance.x - 1):
		curr_direction.x *= -1
	
	# If the platform has hit either edge of its rail on the vertical axis, then flip its direction
	if curr_distance.y + curr_direction.y < min(0, max_distance.y + 1) or curr_distance.y + curr_direction.y > max(0, max_distance.y - 1):
		curr_direction.y *= -1
	
	# Move the sprite
	var tween = create_tween()
	tween.tween_property($".", "position", Vector2(original_position.x + (20 * curr_distance.x), original_position.y + (20 * curr_distance.y)), 0.1)
	
	# Update the current horizontal distance
	curr_distance += curr_direction
