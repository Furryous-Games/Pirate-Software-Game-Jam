extends VBoxContainer

@onready var effects_node: VBoxContainer = $"."

var all_curr_abilities: Dictionary = {}

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	# Updates each status effect's value
	for ability_name in all_curr_abilities:
		#all_curr_abilities[ability_name]["label"]
		#all_curr_abilities[ability_name]["timer"]
		# Do nothing if no abilities
		if !(all_curr_abilities[ability_name]["timer"] == null):
			# If the timer instance is invalid, remove the ability
			if not is_instance_valid(all_curr_abilities[ability_name]["timer"]):
				all_curr_abilities[ability_name]["label"].queue_free()
				continue
			
			# Hides the status effect if its not visible
			if all_curr_abilities[ability_name]["timer"].is_stopped():
				all_curr_abilities[ability_name]["label"].visible = false
			else:
				all_curr_abilities[ability_name]["label"].visible = true
			
			# Gets the rounded time left on the ability
			var time_left = snappedf(all_curr_abilities[ability_name]["timer"].time_left, 0.01)
			
			# Updates the text
			all_curr_abilities[ability_name]["label"].text = ability_name + ": " + ("0" if time_left < 10.00 else "") + ("%.2f" % time_left) + " "


func make_new_ability(ability_name: String, new_timer: Timer = null) -> void:
	# Make a new label
	var new_effect = preload("res://scenes/effect_label.tscn").instantiate()
	effects_node.add_child(new_effect)
	
	all_curr_abilities[ability_name] = {
		"label": new_effect,
		"timer": new_timer,
	}
