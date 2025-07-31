extends Area2D

@onready var reactor: Node2D = $"../../.."
@onready var player: CharacterBody2D = $"../../../../../Player"
@onready var cooldown: Timer = $Cooldown
@onready var sprite: AnimatedSprite2D = $Sprite

var is_on := true

func _on_body_entered(body: Node2D) -> void:
	if not (
			not is_on
			or body is CharacterBody2D 
			or player.can_dash
	):
		return
	
	player.can_dash = true
	sprite.animation = "Off"
	is_on = false
	cooldown.start()


func _on_cooldown_timeout() -> void:
	sprite.animation = "On"
	is_on = true
