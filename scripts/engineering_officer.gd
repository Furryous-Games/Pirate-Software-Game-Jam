extends Node2D

@export var sector_main: Node2D

@export var engineering_officer_door_node: Node2D

var initial_interact = true

## TIMER TOGGLING FUNCTIONS
func _enable_timer(initial_value: int, function_on_timeout = null):
	sector_main.main_script.toggle_timer(true, initial_value, Color.FIREBRICK, function_on_timeout)

func _disable_timer():
	sector_main.main_script.toggle_timer(false)

## BOSS TERMINAL INTERACT
func _officer_terminal_interacted():
	print("TERMINAL")
	
	# Handles the initial interaction with the officer
	if initial_interact:
		_enable_timer(60, _officer_battle_timeout)
		
		engineering_officer_door_node.get_node("Room Lock").toggle_door(false)
		
		engineering_officer_door_node.get_node("Door A").toggle_door(true)
		engineering_officer_door_node.get_node("Door B").toggle_door(true)
		engineering_officer_door_node.get_node("Door C").toggle_door(true)
		engineering_officer_door_node.get_node("Door D").toggle_door(true)
		
		get_node("../Timing Mechanisms").wait_time *= 0.75
		
		initial_interact = false

func _officer_battle_timeout():
	print("TIMEOUT")


## TASKS
func _on_complete_task(task_name: String) -> void:
	print("TASK COMPLETE: ", task_name)
