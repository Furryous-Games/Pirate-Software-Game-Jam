extends Area2D

func _ready() -> void:
	print("dash recharge ready")
	self.body_entered.connect($"../../../".dash_recharge_entered)
