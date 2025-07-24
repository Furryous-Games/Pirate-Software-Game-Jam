extends Area2D

@export var officer_name: String
@onready var officer_prompt: Label = $Prompt

signal officer_interacted


func _ready() -> void:
	officer_prompt.text = officer_name


func interact_with_terminal() -> void:
	print("INTERACT OFFICER")
	# Emit a signal to notify that the terminal was interacted with
	emit_signal("officer_interacted")
	

func enable_terminal() -> void:
	# Make the interact prompt visible
	officer_prompt.visible = true

func disable_terminal() -> void:
	# Make the interact prompt hidden
	officer_prompt.visible = false


# Called when the player enters into the radius of the terminal
func _on_body_entered(body: Node2D) -> void:
	# Check if the body type is CharacterBody2d (the player)
	if body is CharacterBody2D:
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
