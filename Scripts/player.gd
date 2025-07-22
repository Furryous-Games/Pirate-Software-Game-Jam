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

var current_terminals = []
var last_checked_position
var currently_selected_terminal

func _input(event: InputEvent) -> void:
	# Ignore events that arent currently pressed
	if not event.is_pressed():
		return
	
	# Handles interact actions
	if Input.is_action_just_pressed("interact"):
		if currently_selected_terminal:
			currently_selected_terminal.interact_with_terminal()

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

	# Handles movement actions
	if Input.is_action_just_pressed("move_down"):
		set_collision_mask_value(2, false)
	if Input.is_action_just_released("move_down"):
		set_collision_mask_value(2, true)

	move_and_slide()
	
	enable_closest_terminal()


func enable_closest_terminal() -> void:
	# If there are no currently detected terminals, do nothing
	if current_terminals.is_empty():
		currently_selected_terminal = null
		return
	
	# If the current terminals detected are the same as the last ones detected, do nothing
	if position == last_checked_position:
		return
	
	# Set the last checked position to the current one
	last_checked_position = position
	
	# If there is only 1 currently detected terminal, enable that terminal
	if len(current_terminals) == 1:
		if current_terminals[0] != currently_selected_terminal:
			current_terminals[0].enable_terminal()
			
			currently_selected_terminal = current_terminals[0]
	# Otherwise, find the closest terminal to the player
	else:
		var closest_terminal
		
		# Loop through all terminals within range
		for terminal in current_terminals:
			# If there isnt a current closest terminal, the current terminal is the closest
			if closest_terminal == null:
				closest_terminal = terminal
				continue
			# If the current terminal is closer than the closest terminal, the current terminal is the new closest terminal
			elif terminal.position.distance_to(position) < closest_terminal.position.distance_to(position):
				closest_terminal = terminal
				continue
		
		if closest_terminal != currently_selected_terminal:
			# Disable all terminals that isnt the closest one
			for terminal in current_terminals:
				if terminal != closest_terminal:
					terminal.disable_terminal()
			
			# Enable the closest terminal
			closest_terminal.enable_terminal()
			
			# Set the currently selected terminal
			currently_selected_terminal = closest_terminal
