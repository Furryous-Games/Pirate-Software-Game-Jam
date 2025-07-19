extends CharacterBody2D

@onready var internal_collider_check: ShapeCast2D = $"Internal Collider Check"

const JUMP_VELOCITY = -330
const SPEED = 100

var direction

var gravity_change = 1

var gravity_sector = true 

func rotate_char(gravity_change) -> void:
	var rotate = create_tween()
	if gravity_change == -1:
		rotate.tween_property($".", "rotation_degrees", 180, 0.4) # Rotate to 180 degrees in 1 second
	else:
		rotate.tween_property($".", "rotation_degrees", 0, 0.4) # Rotate to 180 degrees in 1 second

func _physics_process(delta: float) -> void:
	# Do not process physics when inside of an object
	if internal_collider_check.is_colliding():
		position.y -= 5
		
		velocity = Vector2(0, 0)
		return
	
	# Gravity mechanic
	
	if Input.is_action_just_pressed("gravity_change") and gravity_sector:
		gravity_change *= -1
		rotate_char(gravity_change)
	
	if not is_on_floor() or gravity_change != 1:
		velocity += get_gravity() * gravity_change * delta
	
	# Jump action
	if Input.is_action_pressed("jump"):
		if gravity_change == 1 and is_on_floor():
			velocity.y = JUMP_VELOCITY * gravity_change
		if gravity_change == -1 and is_on_ceiling():
			velocity.y = JUMP_VELOCITY * gravity_change
	
	# Horizontal Movement
	if Input.is_action_pressed("move_left"):
		direction = -1
	elif Input.is_action_pressed("move_right"):
		direction = 1
	else:
		direction = 0
	
	velocity.x = SPEED * direction
	
	
	move_and_slide()
