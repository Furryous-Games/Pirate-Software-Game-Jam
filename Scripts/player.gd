extends CharacterBody2D

const JUMP_VELOCITY = -330
const SPEED = 100

var direction

func _physics_process(delta: float) -> void:
	# Gravity mechanic
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Jump action
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Horizontal Movement
	if Input.is_action_pressed("move_left"):
		direction = -1
	elif Input.is_action_pressed("move_right"):
		direction = 1
	else:
		direction = 0
	
	velocity.x = SPEED * direction
	
	move_and_slide()
