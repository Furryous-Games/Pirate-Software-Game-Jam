extends Node2D

@export var sector_main: Node2D

@export var engineering_officer_door_node: Node2D
@export var items_node: Node2D
@export var officer_script: Node2D

var officer_battle_ongoing: bool = false
var officer_battle_complete: bool = false


var curr_terminal_task: int = -1
var terminal_tasks = [
	{
		"prompt": "Run Diagnostics",
		"required_item": null,
		"use_item": false,
	},
	{
		"prompt": "Remove Faceplate\n(Needs Wrench)",
		"required_item": "Wrench",
		"use_item": false,
	},
	{
		"prompt": "Repair Wiring\n(Needs Cable)",
		"required_item": "Cable",
		"use_item": true,
	},
	{
		"prompt": "Replace Fuse\n(Needs Fuse)",
		"required_item": "Fuse",
		"use_item": true,
	},
	{
		"prompt": "Replace Faceplate\n(Needs Wrench)",
		"required_item": "Wrench",
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
	"coolant_loop_flushed": false,
	"servers_rebooted": false,
	"clock_rebooted": false
}


func _ready() -> void:
	update_officer_task()


## TIMER TOGGLING FUNCTIONS
func _enable_timer(initial_value: int, function_on_timeout = null):
	sector_main.main_script.toggle_timer(true, initial_value, Color.FIREBRICK, function_on_timeout)

func _disable_timer():
	sector_main.main_script.toggle_timer(false)

## BOSS TERMINAL INTERACT
func _officer_terminal_interacted():
	# Handles the initial interaction with the officer
	if curr_terminal_task <= 0:
		_enable_timer(60, _officer_battle_timeout)
		
		# Set the officer battle variable
		officer_battle_ongoing = true
		
		# Open the doors
		toggle_doors(true)
		
		get_node("../Timing Mechanisms").wait_time *= 0.75
		
		update_officer_task()
	else:
		if terminal_tasks[curr_terminal_task]["required_item"] == null:
			update_officer_task()
		elif sector_main.main_script.player.current_held_item:
			if terminal_tasks[curr_terminal_task]["required_item"] == sector_main.main_script.player.current_held_item.item_name:
				# Remove the item if the task uses the item
				if terminal_tasks[curr_terminal_task]["use_item"]:
					# Reset and disable the item
					sector_main.main_script.player.current_held_item.use_item()
					
					# Make the player drop the item
					sector_main.main_script.player.current_held_item = null
				
				update_officer_task()

func _officer_battle_timeout():
	print("RESET")
	if not officer_battle_complete:
		# Kill the player
		sector_main.main_script.player.death()
		
		# Reset the battle
		reset_battle()
		

func reset_battle():
	if not officer_battle_complete:
		# Disable the timer
		_disable_timer()
		
		# Refill the water in the coolant room
		sector_main.fill_water_layer(Vector2i(210, 11), Vector2i(10, 3))
		sector_main.fill_water(Vector2i(210, 12), Vector2i(10, 2))
		
		# Reset the officer's interactions
		curr_terminal_task = -1
		
		# Update the officer's task
		update_officer_task()
		
		# Set the officer battle variable
		officer_battle_ongoing = false
		
		# Reset the tasks
		all_tasks_complete = {
			"repair": false,
			"coolant_loop_flushed": false,
			"servers_rebooted": false,
			"clock_rebooted": false
		}
		
		# Close the doors
		toggle_doors(false)
		
		# Slow down the tick speed of the timing mechanisms
		get_node("../Timing Mechanisms").wait_time /= 0.75
		
		for item in items_node.get_children():
			item.reset_item()


## DOORS
func toggle_doors(enabled):
	# Open the room lock
	engineering_officer_door_node.get_node("Room Lock").toggle_door(not enabled)
	
	# Close all off room doors
	engineering_officer_door_node.get_node("Door A").toggle_door(enabled)
	engineering_officer_door_node.get_node("Door B").toggle_door(enabled)
	engineering_officer_door_node.get_node("Door C").toggle_door(enabled)
	engineering_officer_door_node.get_node("Door D").toggle_door(enabled)
	engineering_officer_door_node.get_node("Door E").toggle_door(enabled)


## TASKS
func _on_complete_task(task_name: String) -> void:
	print("TASK COMPLETE: ", task_name)
	
	if task_name == "coolant_loop_flushed":
		sector_main.drain_water(Vector2i(210, 11))
	
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
		engineering_officer_door_node.get_node("Room Lock").toggle_door(true)
		
		officer_script.set_officer_task("<OPERATING NORMALLY>")
		
		# Slow down the tick speed of the timing mechanisms
		get_node("../Timing Mechanisms").wait_time /= 0.75
		
		print("ALL TASKS OK")
		print(all_tasks_complete)
		
		officer_battle_ongoing = false
		officer_battle_complete = true
		
		# Add sector to completed sector list
		sector_main.main_script.add_completed_sector()
		
		# Open all sector EXIT doors to allow for exit through the sector
		get_node("../Doors/Engineering T1/Exit Door").toggle_door(true)
		get_node("../Doors/Engineering T2/Exit Door").toggle_door(true)
		get_node("../Doors/Engineering P1/Exit Door").toggle_door(true)
		get_node("../Doors/Engineering P2/Exit Door").toggle_door(true)
