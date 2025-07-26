extends CharacterBody2D

signal player_dash

const RUN_SPEED = 120
const ACCELERATION = 1000
const DECELERATION = 1500
const DASH_VELOCITY = 450
const JUMP_VELOCITY = -420
const WALL_SLIDE_VELOCITY_CAP = 100
const TERMINAL_VELOCITY = 400

var room_spawn: Dictionary

var is_coyote_time_active := false
var is_jump_canceled := false
var can_dash := false
var gravity_change: int = 1

var current_terminals: Array = []
var last_checked_position: Vector2
var currently_selected_terminal

@onready var main_script = $"../"

@onready var internal_player_collider: ShapeCast2D = $"Internal Player Collider"
@onready var water_collider: ShapeCast2D = $"Water Collider"
@onready var wall_collider: ShapeCast2D = $WallCollider

@onready var jump_buffer: Timer = $JumpBuffer
@onready var coyote_time: Timer = $CoyoteTime
@onready var dash_time: Timer = $DashTime


func _input(event: InputEvent) -> void:
	# Reduce jump height if input is released early
	if Input.is_action_just_released("jump") and not is_jump_canceled:
		# If not falling
		if sign(velocity.y * gravity_change) == -1:
			velocity.y *= 0.50
		is_jump_canceled = true
		return
	
	# Ignore events that arent currently pressed
	if not event.is_pressed():
		return
	
	# Handles interact actions
	if Input.is_action_just_pressed("interact"):
		if currently_selected_terminal:
			currently_selected_terminal.interact_with_terminal()


func set_room_spawn(points) -> void:
	room_spawn = points


func _physics_process(delta: float) -> void:
	var direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var is_on_ground: bool = is_on_floor() or is_on_ceiling()
	
	# REACTOR: Reset dash
	if (
			main_script.current_sector == main_script.Sector.REACTOR
			and is_on_floor()
			and not can_dash
			and dash_time.is_stopped()
	):
		can_dash = true
	
	# Coyote time enable/disable
	if is_coyote_time_active == (is_on_ground or wall_collider.is_colliding()): # Biconditional
		is_coyote_time_active = not is_coyote_time_active
		if is_coyote_time_active:
			coyote_time.start()
	
	# Update velocity
	if dash_time.is_stopped(): # Prevents velocity change while dashing
		var desired_velocity := Vector2(RUN_SPEED * direction.x, velocity.y + get_gravity().y * delta * gravity_change)
		
		# enforce terminal y velocity for gravity and inverse gravity
		if main_script.current_sector == main_script.Sector.LIFE_SUPPORT:
			desired_velocity.y = clamp(desired_velocity.y, -TERMINAL_VELOCITY, TERMINAL_VELOCITY) 
		
		# Reduce velocity when in water by 15%
		if water_collider.is_colliding():
			desired_velocity *= 0.85
		
		# Cap the vertical velocity if sliding down the wall
		if wall_collider.is_colliding() and direction.x == -get_wall_normal().x:
			if gravity_change == 1:
				desired_velocity.y = min(desired_velocity.y, WALL_SLIDE_VELOCITY_CAP * gravity_change)
			elif gravity_change == -1:
				desired_velocity.y = max(desired_velocity.y, WALL_SLIDE_VELOCITY_CAP * gravity_change)
		
		velocity = Vector2(
				move_toward(velocity.x, desired_velocity.x, (ACCELERATION if sign(velocity.x) == sign(direction.x) else DECELERATION) * delta), 
				desired_velocity.y
		)
	
	# Jump action
	if Input.is_action_just_pressed("jump")	or (is_on_ground and not jump_buffer.is_stopped()): # Input-jump or auto-jump
		if is_on_ground or not coyote_time.is_stopped():
			velocity.y = JUMP_VELOCITY * gravity_change
			is_jump_canceled = false
			jump_buffer.stop()
		else:
			jump_buffer.start()
			# Wall jump
			if wall_collider.is_colliding():
				velocity = Vector2(RUN_SPEED * get_wall_normal().x, JUMP_VELOCITY * gravity_change)
				is_jump_canceled = false
		
	# REACTOR: Dash action
	if (
			main_script.current_sector == main_script.Sector.REACTOR
			and Input.is_action_just_pressed("dash")
			and can_dash
	):
		velocity = round(Vector2.from_angle(direction.angle()) * DASH_VELOCITY) # Corrects diagonal dashing
		player_dash.emit()
		dash_time.start()
		can_dash = false
	
	# LIFE SUPPORT: Invert gravity action
	if (
			main_script.current_sector == main_script.Sector.LIFE_SUPPORT
			and Input.is_action_just_pressed("invert_gravity")
	):
		gravity_invert(true)

	# Handles movement actions
	if Input.is_action_just_pressed("move_down"):
		set_collision_mask_value(2, false)
	if Input.is_action_just_released("move_down"):
		set_collision_mask_value(2, true)
	
	move_and_slide()
	
	enable_closest_terminal()


func _process(_delta: float) -> void:
	if internal_player_collider.is_colliding():
		death()



func death(from_timer_timeout: bool = false) -> void:
	if gravity_change == -1:
		gravity_invert(false)
	
	if main_script.current_sector == main_script.Sector.REACTOR:
		# Reset mechanisms
		main_script.sector_maps.get_child(-1).reset_room()
		
		# If death was caused by the minute timer's timeout, spawn the player at the section checkpoint
		if from_timer_timeout:
			main_script.toggle_mirage_shader(false, 0)
			main_script.toggle_timer(true, 60, Color.WHITE, main_script.reactor_timer_timout)
			position = main_script.sector_maps.get_child(-1).current_section_data.spawn_point
			velocity = Vector2.ZERO
			return
	
	# timeout death for other sectors
	#elif from_timer_timeout:
		#pass
	
	# spawn the player at the beginning of the room
	position = room_spawn[main_script.current_room]
	velocity = Vector2.ZERO



#inverts gravity for the player, flag denotes if the player roatates with a smooth (true) or abrupt (false) transition
func gravity_invert(flag) -> void:
	gravity_change *= -1
	var rotate_player = create_tween()
	rotate_player.tween_property(self, "rotation_degrees", 0 if gravity_change == 1 else 180, 0.3 if flag else 0.0)
	

func recharge_dash() -> void:
	can_dash = true

	
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
		var closest_terminal = null
		
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
