extends CharacterBody2D

@onready var internal_collider_check: ShapeCast2D = $"Internal Collider Check"

const JUMP_VELOCITY = -330
const SPEED = 100

var direction

func _physics_process(delta: float) -> void:
	# Do not process physics when inside of an object
	#if internal_collider_check.is_colliding():
		#position.y -= 5
		#
		#velocity = Vector2(0, 0)
		#return
	
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
