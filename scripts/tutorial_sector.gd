extends Node2D

@onready var main_script: Node2D = $"../../"

@onready var cell_elevator: AnimatableBody2D = $"Door/Cell Elevator"

@onready var airlock_door_1: AnimatableBody2D = $"Door/Airlock 1"
@onready var airlock_door_2: AnimatableBody2D = $"Door/Airlock 2"

@onready var training_officer: Node2D = $"Training Officer"

func _ready() -> void:
	# Delays the tutorial start
	get_tree().create_timer(0.5).timeout.connect(start_tutorial)


func get_room_spawn_position(room: Vector2i = Vector2i.ZERO) -> Vector2i:
	var room_spawn: Vector2i
	match room:
		# Worker Room
		Vector2i(0, 0): room_spawn = Vector2i(350, 290)
		# Jump Tutorial
		Vector2i(1, 0): room_spawn = Vector2i(730, 230)
		# Terminal Tutorial
		Vector2i(2, 0): room_spawn = Vector2i(1180, 150)
		# Water Tutorial
		Vector2i(3, 0): room_spawn = Vector2i(1760, 150)
		# Officer Repair Tutorial
		Vector2i(4, 0): room_spawn = Vector2i(2560, 230)
	return room_spawn


## TUTORIAL FUNCTIONS
func start_tutorial() -> void:
	cell_elevator.toggle_door(true)

func airlock_puzzle() -> void:
	airlock_door_1.timed_toggle(1)
	airlock_door_2.timed_toggle(1)
	
	airlock_door_1.toggle_door(false)
	airlock_door_2.toggle_door(false)
	pass


## RESETTING THE TRAINING OFFICER BATTLE
func reset_room() -> void:
	training_officer._officer_battle_timeout()
