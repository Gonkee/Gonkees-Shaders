extends Control


onready var input_box = get_node("input")
onready var output_box = get_node("output")
onready var command_handler = get_node("command_handler")

var commandhistoryline = CommandHistory.history.size()

func _ready():
	input_box.grab_focus()

func _process(delta):
	if Input.is_action_just_pressed("toggle_console"):
		get_tree().paused = false
		queue_free()

func _input(event):
	if event is InputEventKey and event.is_pressed():
		if event.scancode == KEY_UP:
			goto_command_history(-1)
		if event.scancode == KEY_DOWN:
			goto_command_history(1)

func goto_command_history(offset):
	commandhistoryline += offset
	commandhistoryline = clamp(commandhistoryline, 0, CommandHistory.history.size())
	if commandhistoryline < CommandHistory.history.size() and CommandHistory.history.size() > 0:
		input_box.text = CommandHistory.history[commandhistoryline]
		input_box.call_deferred("set_cursor_position", 99999999)

func process_command(text):
	var words = text.split(" ")
	words = Array(words)
	
	for i in range(words.count("")):
		words.erase("")
	
	if words.size() == 0:
		return
	
	CommandHistory.history.append(text)
	
	var command_word = words.pop_front()
	
	for c in command_handler.valid_commands:
		if c[0] == command_word:
			if words.size() != c[1].size():
				output_text(str('Failure executing command "', command_word, '", expected ', c[1].size(), ' parameters'))
				return
			for i in range(words.size()):
				if not check_type(words[i], c[1][i]):
					output_text(str('Failure executing command "', command_word, '", parameter ', (i + 1),
								' ("', words[i], '") is of the wrong type'))
					return
			output_text(command_handler.callv(command_word, words))
			return
	output_text(str('Command "', command_word, '" does not exist.'))

func check_type(string, type):
	if type == command_handler.ARG_INT:
		return string.is_valid_integer()
	if type == command_handler.ARG_FLOAT:
		return string.is_valid_float()
	if type == command_handler.ARG_STRING:
		return true
	if type == command_handler.ARG_BOOL:
		return (string == "true" or string == "false")
	return false

func output_text(text):
	output_box.text = str(output_box.text, "\n", text)
	output_box.set_v_scroll(9999999)


func _on_input_text_entered(new_text):
	input_box.clear()
	process_command(new_text)
	commandhistoryline = CommandHistory.history.size()
