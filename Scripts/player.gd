extends CharacterBody2D

const RUN_SPEED = 160
const CLIMB_SPEED = -120
const ACCELERATION = 1000
const DECELERATION = 1500
const DASH_VELOCITY = 380
const JUMP_VELOCITY = -420
const GRAVITY = 1440 # get_gravity().y * 1.6

var can_dash := false

@onready var jump_buffer: Timer = $JumpBuffer
@onready var coyote_time: Timer = $CoyoteTime
@onready var dash_time: Timer = $DashTime

@onready var Sector = $"../".Sector
@onready var current_sector = $"../".current_sector


func _physics_process(delta: float) -> void:
	var direction := Vector2(
			Input.get_axis("move_left", "move_right"), 
			Input.get_axis("move_up", "move_down")
	)
	var climbing: bool = Input.is_action_pressed("climb") and is_on_wall() 
	# NOTE: To climb, you must hold direction.x
	
	# Reset dash, Logistics only
	if (
			current_sector == Sector.LOGISTICS
			and is_on_floor()
			and not can_dash
			and dash_time.is_stopped()
	):
		can_dash = true
	
	# Coyote time
	if not (
			velocity.y 
			or is_on_floor()
			or is_on_wall()
	):
		coyote_time.start()
	
	# Update velocity
	if dash_time.is_stopped(): # Prevents velocity change while dashing
		var desired_velocity := Vector2(
				# x:
				RUN_SPEED * direction.x * int(not climbing),
				# y:
				0.0 if is_on_floor()
				else CLIMB_SPEED * -direction.y if climbing
				else velocity.y + GRAVITY * delta
		)
		var velocity_acceleration: int = ACCELERATION if sign(velocity.x * direction.x) == 1 else DECELERATION
		
		velocity = Vector2(move_toward(velocity.x, desired_velocity.x, velocity_acceleration * delta), desired_velocity.y)
	
	# Jump action
	if (
			Input.is_action_just_pressed("jump")
			or is_on_floor() and not jump_buffer.is_stopped()
	):
		if is_on_floor() or not coyote_time.is_stopped():
			velocity.y = JUMP_VELOCITY
			jump_buffer.stop()
		else:
			jump_buffer.start()
			# Wall jump
			if is_on_wall():
				velocity.y = JUMP_VELOCITY
				velocity.x = RUN_SPEED * get_wall_normal().x
	
	# Dash action, Logistics only
	if (
			current_sector == Sector.LOGISTICS
			and Input.is_action_just_pressed("dash")
			and can_dash
	):
		velocity = round(Vector2.from_angle(direction.angle()) * DASH_VELOCITY) # Corrects diagonal dashing
		dash_time.start()
		can_dash = false
	
	move_and_slide()
