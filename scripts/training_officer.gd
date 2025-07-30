extends Node2D

@export var sector_main: Node2D

@onready var officer_script: Area2D = $Officer

@onready var officer_exit_1: AnimatableBody2D = $"../Door/Officer Exit 1"
@onready var officer_exit_2: AnimatableBody2D = $"../Door/Officer Exit 2"

var terminal_repaired: bool = false

var curr_terminal_task: int = -1
var terminal_tasks = [
	{
		"prompt": "Run Diagnostics",
		"required_item": null,
		"use_item": false,
	},
	{
		"prompt": "Whack With a Wrench\n(Needs Wrench)",
		"required_item": "Wrench",
		"use_item": false,
	},
	{
		"prompt": "<TERMINAL OK>",
		"required_item": null,
		"use_item": false,
	},
]

## ON READY
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
		
		officer_exit_1.toggle_door(false)
		officer_exit_2.toggle_door(false)
		
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
	if not terminal_repaired:
		# Reset the officer task
		curr_terminal_task = -1
		update_officer_task()
		
		# Open the left door
		officer_exit_1.toggle_door(true)
		
		# Reset all items
		get_node("Wrench").reset_item()
		
		# Disable the timer
		_disable_timer()


func update_officer_task() -> void:
	if curr_terminal_task < len(terminal_tasks) - 1:
		curr_terminal_task += 1
	
	officer_script.set_officer_task(terminal_tasks[curr_terminal_task]["prompt"])
	
	if curr_terminal_task == len(terminal_tasks) - 1:
		terminal_repaired = true
		
		# Open both doors
		officer_exit_1.toggle_door(true)
		officer_exit_2.toggle_door(true)
		
		# Disable the timer
		_disable_timer()
