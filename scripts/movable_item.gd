extends CharacterBody2D

@export var item_name: String
@export var item_descriptor: String

@onready var item_name_label: Label = $"VBoxContainer/Item Name"
@onready var item_descriptor_label: Label = $"VBoxContainer/Item Descriptor"

@onready var collider: CollisionShape2D = $Collider
@onready var area_check: Area2D = $"Area Check"

@onready var item_sprite: AnimatedSprite2D = $"Item Sprite"

var player: CharacterBody2D

var original_pos: Vector2

signal pickup_item


func _ready() -> void:
	item_name_label.text = item_name
	item_descriptor_label.text = item_descriptor
	
	original_pos = position
	
	print("\n", item_name)
	print(item_sprite.sprite_frames.get_animation_names())
	
	if item_name in item_sprite.sprite_frames.get_animation_names():
		item_sprite.play(item_name)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	else:
		velocity.x *= 0.9
	
	move_and_slide()


func interact_with_terminal() -> void:
	print("PICK UP ITEM")
	# Emit a signal to notify that the terminal was interacted with
	emit_signal("pickup_item")
	
	if player:
		player.carry_new_item()
	

func enable_terminal() -> void:
	# Make the interact prompt visible
	item_name_label.visible = true
	if item_descriptor != "":
		item_descriptor_label.visible = true
func disable_terminal() -> void:
	# Make the interact prompt hidden
	item_name_label.visible = false
	item_descriptor_label.visible = false


func drop_item() -> void:
	area_check.monitoring = true
	collider.disabled = false
	
	velocity.x *= 1.5

func reset_item() -> void:
	print("RESETTING ITEM")
	drop_item()
	position = original_pos
	velocity = Vector2.ZERO
	
	visible = true

func disable_item() -> void:
	area_check.monitoring = false
	visible = false

func use_item() -> void:
	reset_item()
	disable_item()


# Called when the player enters into the radius of the item
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
