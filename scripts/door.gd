extends AnimatableBody2D

@export var door_shift: int

@export var door_size: Vector2i = Vector2i(1, 1)

@export var closed: bool = false
@export var horizontal_door: bool = false

@export var single_interact: bool = false

@onready var door_sprite: TileMapLayer = $"Door Visual"
@onready var door_collider: CollisionShape2D = $"Door Collider"

@onready var door_hold_timer: Timer = $"Door Hold Timer"


var original_position
var has_interacted: bool = false


func _ready() -> void:
	original_position = position
	
	# Expand the platform to its set size
	expand_door(door_size)
	
	# Update the position of the door
	update_door_position()


func expand_door(new_size: Vector2i) -> void:
	for x in range(new_size.x):
		for y in range(new_size.y):
			door_sprite.set_cell(Vector2i(x, y), 1, Vector2i(14, 3))
	
	door_collider.shape.size = new_size * 20
	door_collider.position = (new_size - Vector2i.ONE) * 10


func timed_toggle(toggle_time: int, toggle_state = null):
	print("TOGGLE ON")
	
	# If there is a set toggle state, set the metadata for the timer to the opposite
	if toggle_state:
		door_hold_timer.set_meta("toggle_state", not toggle_state)
	
	# Toggle the door
	toggle_door(toggle_state)
	
	# Set the wait timer and start the timer
	door_hold_timer.wait_time = toggle_time
	door_hold_timer.start()

func _timed_toggle_timeout() -> void:
	print("TOGGLE OFF")
	# If the door has a toggle state set
	if door_hold_timer.has_meta("toggle_state"):
		# Toggle the door to the set toggle state
		toggle_door(door_hold_timer.get_meta("toggle_state"))
		# Remove the metadata from the timer
		door_hold_timer.remove_meta("toggle_state")
	# Otherwise, just toggle the door
	else:
		toggle_door()


func toggle_door(toggle_state = null):
	# If the door is single interact and has already been interacted with, ignore
	if single_interact and has_interacted:
		return
	
	# If the state has been defined
	if toggle_state:
		closed = not toggle_state
	else:
		# Toggle the door to its opposite state
		closed = not closed
	
	# Make note that the door has been interacted with if single interact is on
	if single_interact:
		has_interacted = true
	
	# Update the position of the door
	update_door_position()

func update_door_position():
	var new_position = original_position
	
	# Get the position for the new door
	if not horizontal_door:
		new_position.y += 20 * ((door_size.y + door_shift) * int(closed))
	else:
		new_position.x += 20 * ((door_size.x + door_shift) * int(closed))
	
	# Move the sprite
	var tween = create_tween()
	tween.tween_property($".", "position", new_position, 0.2)
