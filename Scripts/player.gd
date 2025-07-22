extends CharacterBody2D

@onready var internal_collider_check: ShapeCast2D = $"Internal Collider Check"

const JUMP_VELOCITY = -330
const SPEED = 100

var direction

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
	
	# Handles movement actions
	if Input.is_action_just_pressed("move_down"):
		set_collision_mask_value(2, false)
	if Input.is_action_just_released("move_down"):
		set_collision_mask_value(2, true)
	
	velocity.x = SPEED * direction
	
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
