extends Node

@export var locked: bool
@export var target: Sector

@onready var main_script = $"../../../../"
@onready var portal_sprite: TileMapLayer = $"Portal Visual"
@onready var door_collider: CollisionShape2D = $"Portal Collider"
@onready var key_prompt: Label = $"Key Prompt"
@onready var portal_sfx: AudioStreamPlayer2D = $"Portal SFX"

enum Sector {
	TUTORIAL,
	ATRIUM,
	ENGINEERING,
	LIFE_SUPPORT,
	REACTOR,
	ADMINISTRATIVE,
	ADMINISTRATIVE_OFFICER
}

var sector_list = [&"Tutorial",
	&"Atrium",
	&"Engineering",
	&"Life Support",
	&"Reactor",
	&"Administrative",
	&"ADMINISTRATIVE_OFFICER"]

var open_text: String = "Enter"
var locked_text: String = "Locked"

func _ready() -> void:
	if !locked:
		key_prompt.text = "Enter"
	else:
		key_prompt.text = "Locked"


func unlock_portal() -> void:
	# Toggle the door to its opposite state
	locked = false
	key_prompt.text = "Enter"


func interact_with_terminal() -> void:
	if !locked and !main_script.check_completed_sectors(target):
		main_script.load_sector(target)


func enable_terminal() -> void:
	# Make the interact prompt visible
	key_prompt.visible = true


func disable_terminal() -> void:
	# Make the interact prompt hidden
	key_prompt.visible = false


func _on_body_entered(body: Node2D) -> void:
	# Check if the body type is CharacterBody2d (the player)
	if body is CharacterBody2D:
		# Add self to the current terminals that the player is close to
		body.current_terminals.append(self)


# Called when the player exists the radius of the portal
func _on_body_exited(body: Node2D) -> void:
	# Check if the body type is CharacterBody2d (the player)
	if body is CharacterBody2D:
		disable_terminal()
		
		# Remove self from the current terminals that the player is close to
		if self in body.current_terminals:
			body.current_terminals.erase(self)
