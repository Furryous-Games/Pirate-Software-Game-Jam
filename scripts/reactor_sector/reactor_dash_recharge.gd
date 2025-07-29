extends Area2D

@onready var reactor: Node2D = $"../../.."
@onready var cooldown: Timer = $Cooldown


func _on_body_entered(body: Node2D) -> void:
	if not (visible or body is CharacterBody2D):
		return
	
	reactor.recharge_dash.emit()
	visible = false
	cooldown.start()


func _on_cooldown_timeout() -> void:
	visible = true
