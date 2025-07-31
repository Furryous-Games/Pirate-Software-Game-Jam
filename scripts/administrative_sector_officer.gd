extends Node2D

@export var door_node: Node2D
@export var items_node: Node2D
@export var officer_script: Node2D

@onready var main_script: Node2D = $"../../"
@onready var effects_hud: VBoxContainer = $"../../UI/Effects"

@onready var timing_mechanism_tick_1: TileMapLayer = $"Tilemaps/Mechanism Tick 1"
@onready var timing_mechanism_tick_2: TileMapLayer = $"Tilemaps/Mechanism Tick 2"
@onready var timing_mechanism_tick_3: TileMapLayer = $"Tilemaps/Mechanism Tick 3"
@onready var timing_mechanism_tick_4: TileMapLayer = $"Tilemaps/Mechanism Tick 4"
@onready var timing_mechanism_tick_5: TileMapLayer = $"Tilemaps/Mechanism Tick 5"
@onready var timing_mechanism_tick_6: TileMapLayer = $"Tilemaps/Mechanism Tick 6"
@onready var timing_mechanism_tick_7: TileMapLayer = $"Tilemaps/Mechanism Tick 7"
@onready var timing_mechanism_tick_8: TileMapLayer = $"Tilemaps/Mechanism Tick 8"
@onready var timing_mechanism_tick_9: TileMapLayer = $"Tilemaps/Mechanism Tick 9"

@onready var timing_mechanism_platforms: Node2D = $"Timing Mechanism Platforms"

@onready var timed_gravity_flip: Timer = $"Timed Gravity Flip"
@onready var timed_dash_action: Timer = $"Timed Dash Action"

@onready var dash_platforms: Array[Node] = $DashPlatforms.get_children()
@onready var return_timer: Timer = $ReturnTimer

var all_timing_mechanism_platforms
var curr_timing_mechanism_tick = -1

var curr_terminal_task: int = -1
var terminal_tasks = [
	{
		"prompt": "Run Diagnostics",
		"required_item": null,
		"use_item": false,
	},
	{
		"prompt": "Remove Faceplate\n(Needs Screwdriver)",
		"required_item": "Screwdriver",
		"use_item": false,
	},
	{
		"prompt": "Replace Power Cell\n(Needs Power Cell)",
		"required_item": "Power Cell",
		"use_item": true,
	},
	{
		"prompt": "Replace Coolant\n(Needs Coolant)",
		"required_item": "Coolant",
		"use_item": true,
	},
	{
		"prompt": "Replace Faceplate\n(Needs Screwdriver)",
		"required_item": "Screwdriver",
		"use_item": false,
	},
	{
		"prompt": "<TERMINAL OK>",
		"required_item": null,
		"use_item": false,
	},
]
var all_tasks_complete = {
	"repair": false,
	"restart_droid_servers": false,
	"restart_cryostatis_program": false,
	"stabilize_reactor_cores": false

}

var officer_battle_ongoing = false
var officer_battle_complete = false


func get_room_spawn_position(room: Vector2i = Vector2i.ZERO) -> Vector2i:
	var room_spawn: Vector2i
	match room:
		# Officer Room
		Vector2i(0, 0): room_spawn = Vector2i(290, 220)
		Vector2i(0, 1): room_spawn = Vector2i(290, 220)
		# Left Wing
		Vector2i(-1, 0): room_spawn = Vector2i(290, 220)
		Vector2i(-1, 1): room_spawn = Vector2i(290, 220)
		# Right Wing
		Vector2i(1, 0): room_spawn = Vector2i(290, 220)
		Vector2i(1, 1): room_spawn = Vector2i(290, 220)

	return room_spawn

func _ready() -> void:
	all_timing_mechanism_platforms = [
		timing_mechanism_tick_1, 
		timing_mechanism_tick_2, 
		timing_mechanism_tick_3, 
		timing_mechanism_tick_4, 
		timing_mechanism_tick_5, 
		timing_mechanism_tick_6, 
		timing_mechanism_tick_7, 
		timing_mechanism_tick_8, 
		timing_mechanism_tick_9
		]
	
	# Tick the engineering mechanisms
	_on_timing_mechanism_tick()
	
	return_timer.timeout.connect(
			func(): for platform in dash_platforms:
				platform.move(false)
	)
	
	# Set the timers for the effects hud
	effects_hud.make_new_ability("Gravity Flip", timed_gravity_flip)
	effects_hud.make_new_ability("Dash Action", timed_dash_action)
	
	# Update the officer task
	update_officer_task()

## ENGINEERING FUNCTIONS
func _on_timing_mechanism_tick() -> void:
	# Tick the current mechanism frame
	curr_timing_mechanism_tick = (curr_timing_mechanism_tick + 1) % len(all_timing_mechanism_platforms)
	
	# Hide all platforms
	for platform in all_timing_mechanism_platforms:
		enable_platform_layer(platform, false)
	
	# Enable the current platform frame
	enable_platform_layer(all_timing_mechanism_platforms[curr_timing_mechanism_tick], true)
	
	# Tick all timing mechanism platforms
	for timing_platform in timing_mechanism_platforms.get_children():
		timing_platform._on_timing_mechanism_tick()
func enable_platform_layer(platform_layer: TileMapLayer, enable: bool):
	platform_layer.visible = enable
	platform_layer.collision_enabled = enable

## TIMER TOGGLING FUNCTIONS
func _enable_timer(initial_value: int, function_on_timeout = null):
	main_script.toggle_timer(true, initial_value, Color.WHITE, function_on_timeout)
func _disable_timer():
	main_script.toggle_timer(false)


func dash_ability(wait_time: int) -> void:
	timed_dash_action.wait_time = wait_time

	timed_dash_action.start()

func _gravity_flip(wait_time: int = 10) -> void:
	# Flip the gravity if the timer is disabled
	if timed_gravity_flip.is_stopped():
		main_script.player.gravity_invert()
	
	# Set the new wait time
	timed_gravity_flip.wait_time = wait_time
	
	# Restart the timer
	timed_gravity_flip.start()
func _gravity_flip_timeout() -> void:
	print("FLIP BACK")
	if main_script.player.gravity_change == -1:
		# Flip the gravity back
		main_script.player.gravity_invert()
	
	# Restart the timer
	timed_gravity_flip.stop()
  

## REACTOR FUNCTIONS
func signal_dash() -> void:
	for platform in dash_platforms:
		platform.move(true)
	
	return_timer.start()


## BOSS TERMINAL INTERACT
func _officer_terminal_interacted():
	# Handles the initial interaction with the officer
	if curr_terminal_task <= 0:
		_enable_timer(60, _officer_battle_timeout)
		
		# Set the officer battle variable
		officer_battle_ongoing = true
		
		# Open the doors
		toggle_doors(true)
		
		get_node("Timing Mechanisms").wait_time *= 0.75
		
		update_officer_task()
	else:
		if terminal_tasks[curr_terminal_task]["required_item"] == null:
			update_officer_task()
		elif main_script.player.current_held_item:
			if terminal_tasks[curr_terminal_task]["required_item"] == main_script.player.current_held_item.item_name:
				# Remove the item if the task uses the item
				if terminal_tasks[curr_terminal_task]["use_item"]:
					# Reset and disable the item
					main_script.player.current_held_item.use_item()
					
					# Make the player drop the item
					main_script.player.current_held_item = null
				
				update_officer_task()

func _officer_battle_timeout():
	print("RESET")
	if not officer_battle_complete:
		# Kill the player
		main_script.player.death()
		
		# Reset the battle
		reset_battle()
		

func reset_battle():
	if not officer_battle_complete:
		# Disable the timer
		_disable_timer()
		
		# Reset the officer's interactions
		curr_terminal_task = -1
		
		# Update the officer's task
		update_officer_task()
		
		# Set the officer battle variable
		officer_battle_ongoing = false
		
		# Reset the tasks
		all_tasks_complete = {
			"repair": false,
			"restart_droid_servers": false,
			"restart_cryostatis_program": false,
			"stabilize_reactor_cores": false
		}
		
		# Close the doors
		toggle_doors(false)
		
		# Slow down the tick speed of the timing mechanisms
		get_node("Timing Mechanisms").wait_time /= 0.75
		
		# Reset all items
		for item in items_node.get_children():
			item.reset_item()


## DOORS
func toggle_doors(enabled):
	for door in door_node.get_children():
		door.toggle_door(enabled)
	# Open the left wing
	#door_node.get_node("Left Wing Door").toggle_door(enabled)


## TASKS
func _on_complete_task(task_name: String) -> void:
	print("TASK COMPLETE: ", task_name)
	
	# Make note that the task is complete
	all_tasks_complete[task_name] = true
	
	# Check if all tasks are complete
	check_tasks_complete()

func update_officer_task() -> void:
	if not officer_battle_complete:
		if curr_terminal_task < len(terminal_tasks) - 1:
			curr_terminal_task += 1
		
		officer_script.set_officer_task(terminal_tasks[curr_terminal_task]["prompt"])
		
		if curr_terminal_task == len(terminal_tasks) - 1:
			all_tasks_complete["repair"] = true
		
		# Check if all tasks are complete
		check_tasks_complete()

func check_tasks_complete() -> void:
	print(all_tasks_complete)
	
	if officer_battle_ongoing == true:
		for task in all_tasks_complete:
			if all_tasks_complete[task] == false:
				return
		
		# Disable the timer
		_disable_timer()
		
		# Open the room lock
		door_node.get_node("Room Lock").toggle_door(true)
		
		officer_script.set_officer_task("<OPERATING NORMALLY>")
		
		# Slow down the tick speed of the timing mechanisms
		get_node("../Timing Mechanisms").wait_time /= 0.75
		
		print("ALL TASKS OK")
		print(all_tasks_complete)
		
		officer_battle_ongoing = false
		officer_battle_complete = true
		
		# Open all sector EXIT doors to allow for exit through the sector
		get_node("../Doors/Engineering T1/Exit Door").toggle_door(true)
		get_node("../Doors/Engineering T2/Exit Door").toggle_door(true)
		get_node("../Doors/Engineering P1/Exit Door").toggle_door(true)
		get_node("../Doors/Engineering P2/Exit Door").toggle_door(true)
