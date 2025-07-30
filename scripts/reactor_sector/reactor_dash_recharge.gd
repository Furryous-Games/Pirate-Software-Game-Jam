extends Area2D

@onready var reactor: Node2D = $"../../.."
@onready var player: CharacterBody2D = $"../../../../../Player"
@onready var cooldown: Timer = $Cooldown


func _on_body_entered(body: Node2D) -> void:
	if not (
			visible 
			or body is CharacterBody2D 
			or player.can_dash
	):
		return
	
	player.can_dash = true
	visible = false
	cooldown.start()


func _on_cooldown_timeout() -> void:
	visible = true
