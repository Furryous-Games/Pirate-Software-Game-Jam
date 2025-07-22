extends CharacterBody2D

const RUN_SPEED = 180
const ACCELERATION = 1000
const DECELERATION = 1500
const DASH_VELOCITY = 440
const JUMP_VELOCITY = -420
const CLIMB_SPEED = -120
const GRAVITY = 1440 # get_gravity().y * 1.6

var can_dash := false

@onready var jump_buffer: Timer = $JumpBuffer
@onready var coyote_time: Timer = $CoyoteTime
@onready var dash_time: Timer = $DashTime


func _physics_process(delta: float) -> void:
	var direction := Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down"))
	var climbing: bool = Input.is_action_pressed("climb") and is_on_wall()
	
	# Reset dash
	if $"../".current_sector == $"../".Sector.LOGISTICS:
		if is_on_floor() and not can_dash and dash_time.is_stopped():
			can_dash = true
	
	# Coyote time
	if not (velocity.y or is_on_floor() or is_on_wall()):
		coyote_time.start()
	
	velocity = Vector2(
			# x
			velocity.x if not dash_time.is_stopped()
			else move_toward(velocity.x, RUN_SPEED * direction.x if not climbing else 0.0, (ACCELERATION if direction.x else DECELERATION) * delta),
			
			# y
			velocity.y if not dash_time.is_stopped()
			else 0.0 if is_on_floor()
			else CLIMB_SPEED * -direction.y if climbing
			else velocity.y + GRAVITY * delta
	)
	
	# Jump action
	if Input.is_action_just_pressed("jump") or (is_on_floor() and not jump_buffer.is_stopped()):
		if is_on_floor() or not coyote_time.is_stopped():
			velocity.y = JUMP_VELOCITY
			jump_buffer.stop()
		else:
			jump_buffer.start()
		
			if is_on_wall():
				velocity.y = JUMP_VELOCITY
				velocity.x = RUN_SPEED * get_wall_normal().x
	
	# Dash action
	if $"../".current_sector == $"../".Sector.LOGISTICS:
		if Input.is_action_just_pressed("dash") and can_dash:
			velocity = round(Vector2.from_angle(direction.angle()) * DASH_VELOCITY) # Corrects diagonal dashing
			dash_time.start()
			can_dash = false
	
	move_and_slide()
