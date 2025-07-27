extends Area2D

@onready var reactor: Node2D = $"../../.."


func _on_body_entered(_body: Node2D) -> void:
	reactor.recharge_dash.emit()
