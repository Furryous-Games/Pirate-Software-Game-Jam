extends Panel

enum Prompt {
	INTRO,
	START,
	OPTIONS,
	QUIT,
}

enum ControlLayout {
	LAYOUT_A,
	LAYOUT_B,
	DUAL,
}

var terminal_prompt: Prompt = Prompt.INTRO
var controls: ControlLayout = ControlLayout.DUAL

const INPUT_ACTIONS = [&"jump", &"interact", &"dash", &"invert_gravity"]
const LAYOUT_MAPPINGS = {
	ControlLayout.LAYOUT_A: {
		&"jump": [KEY_UP, KEY_W, KEY_SPACE],
		&"interact": [KEY_E, KEY_ENTER],
		&"dash": [KEY_X],
		&"invert_gravity": [KEY_G],
	},
	ControlLayout.LAYOUT_B: {
		&"jump": [KEY_C],
		&"interact": [KEY_Z],
		&"dash": [KEY_X],
		&"invert_gravity": [KEY_X],
	},
	ControlLayout.DUAL: {
		&"jump": [KEY_UP, KEY_W, KEY_SPACE, KEY_C],
		&"interact": [KEY_E, KEY_ENTER, KEY_Z],
		&"dash": [KEY_X],
		&"invert_gravity": [KEY_G, KEY_X],
	},
}

var tween_text_visibility: Tween
var is_shader_on := true
var is_smooth_camera_on := true
var control_set := "dual"

@onready var main_script: Node2D = $"../.."
@onready var system_text: RichTextLabel = $ConsoleFrame/VBoxContainer/SystemText
@onready var player_input: LineEdit = $ConsoleFrame/VBoxContainer/PlayerInput


func _ready() -> void:
	#set_input_map()
	system_text.text = ""
	system_text.visible_characters = 0
	output(get_output_text(Prompt.INTRO))


func _input(_event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_SLASH):
		player_input.edit()
		tween_text_visibility.kill()


func get_output_text(prompt: Prompt) -> String:
	var text: String
	match prompt:
		Prompt.INTRO: text = (
		"RUNNING DIAGNOSTICS...\n
		SECTOR.Engineering: [color=RED]FATAL:
				Officer unresponsive, sector funcitonality critical[/color]\n
		SECTOR.Life_Support: [color=RED]FATAL:
				Officer unresponsive, sector funcitonality critical[/color]\n
		SECTOR.Reactor: [color=RED]FATAL:
				Officer unresponsive, sector funcitonality critical
				Reactor cooling systems unresponsive, meltdown imminent[/color]
		\nSEARCHING REPAIR DROIDS...\n
		R0: [color=RED]unresponsive[/color]
		R1: [color=RED]unresponsive[/color]
		R2: [color=RED]unresponsive[/color]
		R3: [color=RED]unresponsive[/color]
		R4: [color=GREEN]responsive[/color]
		R5: [color=RED]unresponsive[/color]
		...
		\n// [color=YELLOW]R4[/color], you are the [color=YELLOW]only one[/color] who can restore the Sector Officers\n// Do you accept this undertaking?
		\n[color=DARKGRAY]awaiting input [ yes/no/options ][/color]"
			)
		
		Prompt.START: text = (
		"\n[color=DARKGRAY]> yes[/color]
		\nCHECKING SECTOR FUNCTIONALITY STATUS...\n
		[color=DEEPPINK]ENGINEERING[/color]: Clock systems online
		[color=DEEPPINK]LIFE SUPPORT[/color]: Gravity inversion systems online
		[color=DEEPPINK]REACTOR[/color]: Dash-powered platforms and dash recharges online
		\nEnabling [color=GREEN]R4[/color] movement system...\n
		[color=DEEPPINK]MOVEMENT[/color]: online
		[color=DEEPPINK]JUMP[/color]: online
		[color=DEEPPINK]ACTIVATE TERMINALS[/color]: online
		[color=DEEPPINK]DASH[/color]:  Functionality limited to REACTOR and ADMINISTRATION
		[color=DEEPPINK]GRAVITY INVERT[/color]: Functionality limited to LIFE SUPPORT
		\n//[color=YELLOW]You are humanity's last hope.[/color]\n//The Sector's conditions are critical; move through them with caution.\n//Navigate through each sector and repair th-ANJKFH&^567734y78o8TGyuf;nf;g\n
	[color=RED][ERROR]
	DISCONNECTING FROM ADMINISTRATION...[/color]\n
		
		\n[color=GREEN]connecting to R4...............[/color]"
			)
		
		Prompt.OPTIONS: text = (
		"\n\n[color=AQUA]OPTIONS[/color]
		[color=DEEPPINK]mirage shader[/color] = [color=AQUA]{is_shader_on}[/color]\n
		[color=DEEPPINK]smooth camera transition[/color] = [color=AQUA]{is_smooth_camera_on}[/color]\n
		[color=DEEPPINK]controls[/color] = [color=AQUA]'{controls}'[/color]:
				[color=DARKGRAY]'Layout A' = (
						MOVE = [color=AQUA]WASD/ARROW KEYS[/color] 
						JUMP = [color=AQUA]W/UP/SPACE[/color]
						INTERACT = [color=AQUA]E/ENTER[/color]
						DASH = [color=AQUA]X[/color]
						INVERT GRAVITY = [color=AQUA]G[/color]
						RESTART = [color=AQUA]R[/color]
				)
				'Layout B' = (
						MOVE = [color=AQUA]ARROW KEYS[/color] 
						JUMP = [color=AQUA]C[/color]
						INTERACT = [color=AQUA]Z[/color]
						DASH = [color=AQUA]X[/color]
						INVERT GRAVITY = [color=AQUA]X[/color]
						RESTART = [color=AQUA]R[/color]
				)
				'Dual' = Layout A and B[/color]
		"
			)
	return text


func output(new_text: String, set_prompt: Prompt = Prompt.START, call_function = (func(): player_input.edit()), refresh: bool = false) -> void:
	terminal_prompt = set_prompt
	
	if new_text == "":
		new_text = get_output_text(terminal_prompt)
		
		if terminal_prompt == Prompt.OPTIONS:
			new_text = new_text.format({"is_shader_on": str(is_shader_on), "is_smooth_camera_on": str(is_smooth_camera_on), "controls": control_set})
			
	
	if refresh:
		system_text.visible_characters = 0
		system_text.text = new_text
	else:
		system_text.text += new_text
	
	# Remove BBCode from text to accurately get string length
	var filtered_text_length: String = system_text.text
	for code in ["[color=RED]", "[color=GREEN]", "[color=DARKGRAY]", "[color=YELLOW]", "[color=DEEPPINK]", "[color=AQUA]", "[/color]"]:
		filtered_text_length = filtered_text_length.replace(code, "")
	
	var text_length: int = len(filtered_text_length)
	@warning_ignore("integer_division")
	var text_speed: int = len(new_text) / (40 if terminal_prompt == Prompt.START else 120)
	text_speed = clampi(text_speed, 1, 120)
	
	tween_text_visibility = create_tween()
	tween_text_visibility.tween_property(system_text, "visible_characters", text_length, text_speed)
	tween_text_visibility.finished.connect(call_function)


func _on_player_input_text_submitted(new_text: String) -> void:
	if terminal_prompt == Prompt.START:
		match new_text:
			"no": 
				output("[color=RED]disconnecting R4............[/color]", Prompt.QUIT, (func(): get_tree().quit()), true)
			
			"yes": 
				output("", Prompt.START, (
					func():
						main_script.load_sector(main_script.Sector.ADMINISTRATIVE_OFFICER)
						main_script.player.is_input_paused = false
						self.queue_free()
				))
			
			"options": 
				output("", Prompt.OPTIONS)
			
			"/skip":
				output("Skipping Sequence", Prompt.START, (
					func():

						main_script.load_sector(main_script.Sector.ADMINISTRATIVE_OFFICER)

						main_script.player.is_input_paused = false
						self.queue_free()
				), true)
			
			"/stop":
				system_text.visible_characters = 0
				system_text.text = ""
				player_input.edit()
			
			_: 
				output("[color=DARKGRAY]\ninvalid user input: '" + new_text + "'[/color]")
				player_input.edit()
				
	elif terminal_prompt == Prompt.OPTIONS:
		if new_text == "return":
			output("\n[color=DARKGRAY]awaiting input [ yes/no/options ][/color]", Prompt.START)
		
		# Mirage settings
		elif new_text.containsn("mirage") or new_text.containsn("shader"):
			if new_text.ends_with("true"):
				is_shader_on = true
				main_script.mirage_lock = false
				output("\n[color=DARKGRAY]mirage shader = true[/color]", Prompt.OPTIONS)
			
			elif new_text.ends_with("false"):
				is_shader_on = false
				main_script.mirage_lock = true
				output("\n[color=DARKGRAY]mirage shader = false[/color]", Prompt.OPTIONS)
		
		# Camera settings
		elif new_text.containsn("camera"):
			if new_text.ends_with("true"):
				is_smooth_camera_on = true
				main_script.is_smooth_camera_on = true
				output("\n[color=DARKGRAY]smooth camera = true[/color]", Prompt.OPTIONS)
			
			elif new_text.ends_with("false"):
				is_smooth_camera_on = false
				main_script.is_smooth_camera_on = false
				output("\n[color=DARKGRAY]smooth camera = false[/color]", Prompt.OPTIONS)
		
		## Control settings
		#elif new_text.containsn("controls"):
			#if new_text.ends_with("layout_a"):
				#controls = ControlLayout.LAYOUT_A
				#set_input_map()
			#elif new_text.ends_with("layout_b"):
				#controls = ControlLayout.LAYOUT_B
				#set_input_map()
			#elif new_text.ends_with("dual"):
				#controls = ControlLayout.DUAL
				#set_input_map()
			#else:
				#output("[color=DARKGRAY]\ninvalid user input: '" + new_text + "'[/color]")
				#player_input.edit()
		
		else: 
			output("[color=DARKGRAY]\ninvalid user input: '" + new_text + "'[/color]")
			player_input.edit()
				
	player_input.clear()
	
	
#func set_input_map() -> void:
	#var input := InputEventKey.new()
	#for action in INPUT_ACTIONS:
		## Clear input events for action
		#InputMap.action_erase_events(action)
		## Add event to action
		#for key in LAYOUT_MAPPINGS[controls][action]:
			#input.keycode = key
			#InputMap.action_add_event(action, input)
			#print(action + ": " + str(input))
