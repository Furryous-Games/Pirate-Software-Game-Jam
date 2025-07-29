extends CharacterBody2D

signal player_dash

const RUN_SPEED = 120
const ACCELERATION = 1000
const DECELERATION = 1500
const DASH_VELOCITY = 450
const JUMP_VELOCITY = -420
const WALL_SLIDE_VELOCITY_CAP = 100
const TERMINAL_VELOCITY_LIFE_SUPPORT = 400 # LIFE SUPPORT
const TERMINAL_VELOCITY_REACTOR = Vector2(1000, 400)
const LAUNCH_BOOST = Vector2i(400, 0.2) # REACTOR

var sector: Node2D

var is_coyote_time_active := false
var is_jump_canceled := false
var can_dash := false
var gravity_change: int = 1

var current_terminals: Array = []
var last_checked_position: Vector2
var currently_selected_terminal

var current_held_item: CharacterBody2D
var held_item_pos: Vector2 = Vector2(0, -50)

@onready var main_script = $"../"

@onready var internal_player_collider: ShapeCast2D = $"Internal Player Collider"
@onready var water_collider: ShapeCast2D = $"Water Collider"
@onready var wall_collider: ShapeCast2D = $WallCollider
@onready var launch_collider: ShapeCast2D = $LaunchCollider

@onready var jump_buffer: Timer = $JumpBuffer
@onready var coyote_time: Timer = $CoyoteTime
@onready var dash_time: Timer = $DashTime
@onready var respawn_input_pause: Timer = $RespawnInputPause


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("restart"):
		death()
		return
	
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
		if currently_selected_terminal != null:
			currently_selected_terminal.interact_with_terminal()
		elif current_held_item != null:
			current_held_item.drop_item()
			current_held_item = null


func _physics_process(delta: float) -> void:
	# Prevents input while the RespawnInputPause timer is active
	if not respawn_input_pause.is_stopped():
		move_and_slide()
		return
	
	var direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var is_on_ground: bool = is_on_floor() if gravity_change == 1 else is_on_ceiling()
	
	# REACTOR: Reset dash
	if (
			main_script.current_sector == main_script.Sector.REACTOR
			and is_on_ground
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
		
		# LIFE SUPPORT: Enforce terminal y velocity for gravity and inverse gravity
		if main_script.current_sector == main_script.Sector.LIFE_SUPPORT:
			desired_velocity.y = clamp(desired_velocity.y, -TERMINAL_VELOCITY_LIFE_SUPPORT, TERMINAL_VELOCITY_LIFE_SUPPORT)
		# REACTER: clamp velocity to terminal velocity 
		elif main_script.current_sector == main_script.Sector.REACTOR:
			desired_velocity.y = clamp(desired_velocity.y, -TERMINAL_VELOCITY_REACTOR.y, TERMINAL_VELOCITY_REACTOR.y)
		
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
	
	# REACTOR: Increase velocity.x when launching off platform; clamp velocity
	if (
			main_script.current_sector == main_script.Sector.REACTOR
			and launch_collider.is_colliding()
			and sector.is_launch_active
	):
		velocity.x += LAUNCH_BOOST.x * direction.x
		velocity.y *= LAUNCH_BOOST.y
		velocity = clamp(velocity, -TERMINAL_VELOCITY_REACTOR, TERMINAL_VELOCITY_REACTOR)
	
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
				var wall_jump_boost: float = get_wall_normal().x * (2.5 if direction.x == get_wall_normal().x else 1.0)
				velocity = Vector2(RUN_SPEED * wall_jump_boost, JUMP_VELOCITY * gravity_change)
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
		gravity_invert()

	# Handles movement actions
	if Input.is_action_just_pressed("move_down"):
		set_collision_mask_value(2, false)
	elif Input.is_action_just_released("move_down"):
		set_collision_mask_value(2, true)
	
	# Handles the item the player is holding
	if current_held_item != null:
		# Add a damening to the current item's velocity
		current_held_item.velocity *= 0.8
		# Push the item in the direction of the held item position
		current_held_item.velocity += ((position + held_item_pos) - current_held_item.position) * 2

	move_and_slide()
	
	enable_closest_terminal()


func _process(_delta: float) -> void:
	if internal_player_collider.is_colliding():
		death()


func death(from_timer_timeout: bool = false) -> void:

	curr_held_item = null
	
	match main_script.current_sector:
		
		main_script.Sector.LIFE_SUPPORT:
			#check if player inverted
			if rotation_degrees != 0:
				rotation_degrees = 0
		  	#ensure gravity resets
			if gravity_change == -1:
				gravity_invert()
			
		main_script.Sector.REACTOR:
			# Reset mechanisms
			sector.reset_room()
			
			# If death was caused by the minute timer's timeout, spawn the player at the subsector checkpoint
			if from_timer_timeout:
				main_script.toggle_mirage_shader(false, 0)
				main_script.toggle_timer(true, 60, Color.WHITE, main_script.reactor_timer_timout)
				position = sector.respawn_player_at_subsector()
				velocity = Vector2.ZERO
				return
	
	# timeout death for other sectors
	#elif from_timer_timeout:
		#pass
	
	# spawn the player at the beginning of the room, and ensure player not upside down
	position = sector.get_room_spawn_position(main_script.current_room)
	velocity = Vector2.ZERO
	respawn_input_pause.start()


# Inverts gravity for the player
func gravity_invert() -> void:
	var rotate_player = create_tween()
	rotate_player.tween_property(self, "rotation_degrees", 0 if gravity_change == -1 else 180, 0.2)
	gravity_change *= -1

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


func carry_new_item() -> void:
	print(currently_selected_terminal)
	if currently_selected_terminal is CharacterBody2D:
		# Drop the currently held item if there is one
		if current_held_item:
			current_held_item.drop_item()
		
		print("HOLDING NEW ITEM")
		currently_selected_terminal.collider.disabled = true
		currently_selected_terminal.area_check.monitoring = false
		
		current_held_item = currently_selected_terminal
