extends Area2D

@export var officer_name: String
@onready var officer_name_label: Label = $"VBoxContainer/Officer Name"
@onready var officer_task_label: Label = $"VBoxContainer/Officer Task"

var player: CharacterBody2D

signal officer_interacted


func _ready() -> void:
	officer_name_label.text = officer_name


func set_officer_task(new_task: String) -> void:
	officer_task_label.text = new_task


func interact_with_terminal() -> void:
	# Emit a signal to notify that the terminal was interacted with
	emit_signal("officer_interacted")
	

func enable_terminal() -> void:
	# Make the interact prompt visible
	officer_name_label.visible = true
	officer_task_label.visible = true

func disable_terminal() -> void:
	# Make the interact prompt hidden
	officer_name_label.visible = false
	officer_task_label.visible = false


# Called when the player enters into the radius of the terminal
func _on_body_entered(body: Node2D) -> void:
	# Check if the body type is CharacterBody2d (the player)
	if body is CharacterBody2D:
		player = body
		
		# Add self to the current terminals that the player is close to
		body.current_terminals.append(self)


# Called when the player exists the radius of the terminal
func _on_body_exited(body: Node2D) -> void:
	# Check if the body type is CharacterBody2d (the player)
	if body is CharacterBody2D:
		disable_terminal()
		
		# Remove self from the current terminals that the player is close to
		if self in body.current_terminals:
			body.current_terminals.erase(self)
