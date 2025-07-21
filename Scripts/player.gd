extends CharacterBody2D

const SPEED = 180
const JUMP_VELOCITY = -330
const GRAVITY = 1170 # get_gravity().y * 1.3

@onready var jump_buffer: Timer = $JumpBuffer


func _physics_process(delta: float) -> void:
	# direction.y will be used for dashing and climbing
	var direction := Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_down", "move_up"))
	
	velocity.y = 0.0 if is_on_floor() else velocity.y + GRAVITY * delta
	
	# Jump action
	if Input.is_action_just_pressed("jump") or (is_on_floor() and not jump_buffer.is_stopped()):
		if not jump_buffer.is_stopped():
			print(jump_buffer.time_left)
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			jump_buffer.stop()
		else:
			jump_buffer.start()

	
	velocity.x = SPEED * direction.x
	
	move_and_slide()
