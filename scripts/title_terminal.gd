extends Panel

enum Prompt {
	START,
	OPTIONS,
	QUIT,
}
var terminal_prompt: Prompt

const OUTPUT_TEXT = {
	"intro" : (
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
		\n[color=DARKGRAY]awaiting input [yes/no/options][/color]"
	),
	"prompt_start" : (
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
		\n//[color=YELLOW]You are humanity's last hope.[/color]
		\n//The Sector's conditions are critical; move through them with caution.
		\n//Navigate through each sector and repair the malfunctioning AI Officer, 
		\napproach with caution an-ANJKFH&^567734y78o8TGyuf;nf;gij8w9579&*A
		\nJKLHluf<>heor=u19834789ip9j =1dwpoks<??qu3hr7o=qliu r89 u923 
		\n5o--f8a9<>?>0sfnldhvow- [color=RED][ERROR]\n
		DISCONNECTING FROM ADMINISTRATION...[/color]\n
		
		\n[color=GREEN]connecting to R4...............[/color]"
	),
	"options": (
		"\n[color=AQUA]OPTIONS[/color]"
	),
}

var tween_text_visibility: Tween

@onready var main_script: Node2D = $"../.."
@onready var system_text: RichTextLabel = $ConsoleFrame/VBoxContainer/SystemText
@onready var player_input: LineEdit = $ConsoleFrame/VBoxContainer/PlayerInput


func _ready() -> void:
	system_text.text = ""
	system_text.visible_characters = 0
	output(OUTPUT_TEXT.intro)


func output(new_text: String, call_function = (func(): player_input.edit()), set_prompt: Prompt = Prompt.START, refresh: bool = false) -> void:
	terminal_prompt = set_prompt
	
	if refresh:
		system_text.visible_characters = 0
		system_text.text = new_text
	else:
		system_text.text += new_text
	
	# Remove BBCode from 
	var filtered_text_length: String = system_text.text
	for code in ["[color=RED]", "[color=GREEN]", "[color=DARKGRAY]", "[color=YELLOW]", "[color=DEEPPINK]", "[color=AQUA]", "[/color]"]:
		filtered_text_length = filtered_text_length.replace(code, "")
	
	var text_length: int = len(filtered_text_length)
	@warning_ignore("integer_division")
	var text_speed: int = len(new_text) / 30
	text_speed = clampi(text_speed, 1, 60)
	
	tween_text_visibility = create_tween()
	tween_text_visibility.tween_property(system_text, "visible_characters", text_length, text_speed)
	tween_text_visibility.finished.connect(call_function)


func _on_player_input_text_submitted(new_text: String) -> void:
	if terminal_prompt == Prompt.START:
		match new_text:
			"no": 
				output("So thus humanity meets it's extiction", (func(): get_tree().quit()), Prompt.QUIT, true)
			"yes": 
				tween_text_visibility.stop()
				tween_text_visibility.custom_step(100)
				output(OUTPUT_TEXT.prompt_start, (
					func():
						main_script.load_sector(main_script.Sector.REACTOR)
						main_script.player.is_input_paused = false
						self.queue_free()
				))	
			"options": 
				output(OUTPUT_TEXT.options, func():player_input.edit(), Prompt.OPTIONS)
			"skip":
				output("Skipping Sequence", (
					func():
						main_script.load_sector(main_script.Sector.REACTOR)
						main_script.player.is_input_paused = false
						self.queue_free()
				), Prompt.START, true)
			_: 
				output("[color=DARKGRAY]\ninvalid user input: '" + new_text + "'[/color]")
				player_input.edit()
				
	elif terminal_prompt == Prompt.OPTIONS:
		if new_text.begins_with("mirage shader"):
			output("\nmirage.material:shader_parameter/frequency")
		
	player_input.clear()
