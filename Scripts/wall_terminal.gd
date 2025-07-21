extends Area2D

@onready var key_prompt: Label = $"Key Prompt"


func interact_with_terminal() -> void:
	print("INTERACT")
	

func enable_terminal() -> void:
	# Make the interact prompt visible
	key_prompt.visible = true

func disable_terminal() -> void:
	# Make the interact prompt hidden
	key_prompt.visible = false


# Called when the player enters into the radius of the terminal
func _on_body_entered(body: Node2D) -> void:
	# Add self to the current terminals that the player is close to
	body.current_terminals.append(self)


# Called when the player exists the radius of the terminal
func _on_body_exited(body: Node2D) -> void:
	disable_terminal()
	
	# Remove self from the current terminals that the player is close to
	if self in body.current_terminals:
		body.current_terminals.erase(self)
