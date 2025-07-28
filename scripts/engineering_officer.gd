extends Node2D

@export var sector_main: Node2D

@export var engineering_officer_door_node: Node2D
@export var items_node: Node2D
@export var officer_script: Node2D


var curr_terminal_task = -1
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
		"prompt": "",
		"required_item": null,
		"use_item": false,
	},
]


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
		
		engineering_officer_door_node.get_node("Room Lock").toggle_door(false)
		
		engineering_officer_door_node.get_node("Door A").toggle_door(true)
		engineering_officer_door_node.get_node("Door B").toggle_door(true)
		engineering_officer_door_node.get_node("Door C").toggle_door(true)
		engineering_officer_door_node.get_node("Door D").toggle_door(true)
		
		get_node("../Timing Mechanisms").wait_time *= 0.75
		
		update_officer_task()
	else:
		if terminal_tasks[curr_terminal_task]["required_item"] == null:
			update_officer_task()
		elif sector_main.main_script.player.curr_held_item:
			if terminal_tasks[curr_terminal_task]["required_item"] == sector_main.main_script.player.curr_held_item.item_name:
				# Remove the item if the task uses the item
				if terminal_tasks[curr_terminal_task]["use_item"]:
					# Reset and disable the item
					sector_main.main_script.player.curr_held_item.use_item()
					
					# Make the player drop the item
					sector_main.main_script.player.curr_held_item = null
				
				update_officer_task()

func _officer_battle_timeout():
	print("TIMEOUT")
	# Disable the timer
	_disable_timer()
	
	# Reset the officer's interactions
	curr_terminal_task = -1
	
	# Update the officer's task
	update_officer_task()
	
	# Kill the player
	sector_main.main_script.player.death()
	
	# Open the room lock
	engineering_officer_door_node.get_node("Room Lock").toggle_door(true)
	
	# Close all off room doors
	engineering_officer_door_node.get_node("Door A").toggle_door(false)
	engineering_officer_door_node.get_node("Door B").toggle_door(false)
	engineering_officer_door_node.get_node("Door C").toggle_door(false)
	engineering_officer_door_node.get_node("Door D").toggle_door(false)
	
	# Slow down the tick speed of the timing mechanisms
	get_node("../Timing Mechanisms").wait_time /= 0.75
	
	for item in items_node.get_children():
		item.reset_item()


## TASKS
func _on_complete_task(task_name: String) -> void:
	print("TASK COMPLETE: ", task_name)

func update_officer_task() -> void:
	if curr_terminal_task < len(terminal_tasks) - 1:
		curr_terminal_task += 1
	
	officer_script.set_officer_task(terminal_tasks[curr_terminal_task]["prompt"])
