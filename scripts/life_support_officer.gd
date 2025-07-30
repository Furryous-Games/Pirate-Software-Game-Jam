extends Node2D

@export var officer_script: Node2D
@export var sector_main: Node2D
@export var items_node: Node2D
@export var door_node: Node2D

var officer_battle_ongoing: bool = false
var gravity_terminal_toggle: bool = false
var server_room_toggle: bool = false
var curr_terminal_task: int = -1

var task_order = ["diagnostic1", "server", "diagnostic2", "gravity", "card", "OK"]

var all_tasks_complete = {
	"diagnostic1": true,
	"server": false,
	"diagnostic2": true,
	"gravity": false,
	"card": false,
}

var terminal_tasks = [
	{
		"prompt": "Run Diagnostics",
		"required_item": null,
		"use_item": false,
	},
	{
		"prompt": "Servers Overheating, Flood Server Room",
		"required_item": null,
		"use_item": false,
	},
	{
		"prompt": "Re-Run Diagnostics",
		"required_item": null,
		"use_item": false,
	},
	{
		"prompt": "Fix Localized Gravity Fields",
		"required_item": null,
		"use_item": false,
	},
	{
		"prompt": "Need Access Card",
		"required_item": "Card",
		"use_item": true,
	},
	{
		"prompt": "<TERMINAL OK>",
		"required_item": null,
		"use_item": false,
	},
]


func _ready() -> void:
	update_officer_task()


func update_officer_task() -> void:
	if curr_terminal_task < len(terminal_tasks) - 1:
		curr_terminal_task += 1
	
	officer_script.set_officer_task(terminal_tasks[curr_terminal_task]["prompt"])
	
	if task_order[curr_terminal_task] == "gravity":
		sector_main.main_script.player.gravity_invert()
		sector_main.main_script.player.enable_disable_gravity(false)
		sector_main.gravity_diabeld_toggle()
	
	# Check if all tasks are complete
	check_tasks_complete()


func _on_complete_task(task_name: String) -> void:
	print("TASK COMPLETE: ", task_name)
	
	match task_name:
		"server":
			if !server_room_toggle:
				door_node.get_node("Operator/Door 4").toggle_door(false)
				door_node.get_node("Operator/Door 5").toggle_door(true)
				door_node.get_node("Operator/Door 6").toggle_door(true)
				sector_main.fill_waterfall(Vector2i(159, 33), Vector2i(18,1))
				sector_main.drain_water(Vector2i(146, 18))
				sector_main.fill_water_bottom(Vector2i(156, 48), Vector2i(18,1))
				server_room_toggle = true
				update_officer_task()
		
		"gravity":
			if !gravity_terminal_toggle:
				sector_main.main_script.player.enable_disable_gravity(true)
				sector_main.main_script.player.gravity_invert()
				gravity_terminal_toggle = true
				update_officer_task()
	
	# Make note that the task is complete
	all_tasks_complete[task_name] = true
	
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
		#engineering_officer_door_node.get_node("Room Lock").toggle_door(true)
		
		officer_script.set_officer_task("<OPERATING NORMALLY>")
		
		# Slow down the tick speed of the timing mechanisms
		#get_node("../Timing Mechanisms").wait_time /= 0.75
		
		print("ALL TASKS OK")
		print(all_tasks_complete)
		
		officer_battle_ongoing = false


func _enable_timer(initial_value: int, function_on_timeout = null):
	sector_main.main_script.toggle_timer(true, initial_value, Color.FIREBRICK, function_on_timeout)


func _disable_timer():
	sector_main.main_script.toggle_timer(false)


func _officer_terminal_interacted():
	if curr_terminal_task <= 0:
		_enable_timer(60, _officer_battle_timeout)
		
		# Set the officer battle variable
		officer_battle_ongoing = true
		
		# Open the doors
		toggle_doors(false)
		
		update_officer_task()
	elif task_order[curr_terminal_task] == "OK":
		return
	else:
		print(task_order[curr_terminal_task], all_tasks_complete)
		if terminal_tasks[curr_terminal_task]["required_item"] == null:
			if all_tasks_complete[task_order[curr_terminal_task]] == true:
				update_officer_task()
			else:
				return
		elif sector_main.main_script.player.current_held_item:
			if terminal_tasks[curr_terminal_task]["required_item"] == sector_main.main_script.player.current_held_item.item_name:
				# Remove the item if the task uses the item
				if terminal_tasks[curr_terminal_task]["use_item"]:
					# Reset and disable the item
					sector_main.main_script.player.current_held_item.use_item()
					
					# Make the player drop the item
					sector_main.main_script.player.current_held_item = null
					
					#Update task list 
					all_tasks_complete[task_order[curr_terminal_task]] = true
					
				update_officer_task()


func toggle_doors(enable):
	door_node.get_node("P2/Door 3").toggle_door(!enable)
	door_node.get_node("Operator/Door 4").toggle_door(!enable)
	door_node.get_node("Operator/Door 5").toggle_door(!enable)
	door_node.get_node("Operator/Door 6").toggle_door(!enable)


func _officer_battle_timeout():
	print("TIMEOUT")
	# Disable the timer
	_disable_timer()
	
	# Kill the player
	sector_main.main_script.player.death(true)
	
	# Fill up the tub, boy
	sector_main.drain_water(Vector2i(159, 33), false)
	sector_main.fill_water_top(Vector2i(165, 18), Vector2i(18,1))
	
	# Reset tasks
	curr_terminal_task = -1
	
	update_officer_task()
	
	all_tasks_complete = {
	"diagnostic1": true,
	"server": false,
	"diagnostic2": true,
	"gravity": false,
	"card": false,
	}
	
	# Set the officer battle variable
	officer_battle_ongoing = false
	
	# Reset doors
	toggle_doors(true)
	
	sector_main.main_script.player.enable_disable_gravity(true)
	sector_main.gravity_diabeld_toggle()
	
	gravity_terminal_toggle = false
	server_room_toggle = false
	
	# Reset items
	for item in items_node.get_children():
		item.reset_item()
