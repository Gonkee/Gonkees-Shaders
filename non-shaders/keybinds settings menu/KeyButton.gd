extends Button

var key
var value
var menu

var waiting_input = false

func _input(event):
	if waiting_input:
		if event is InputEventKey:
			value = event.scancode
			text = OS.get_scancode_string(value)
			menu.change_bind(key, value)
			pressed = false
			waiting_input = false
		if event is InputEventMouseButton:
			if value != null:
				text = OS.get_scancode_string(value)
			else:
				text = "Unassigned"
			pressed = false
			waiting_input = false

func _toggled(button_pressed):
	if button_pressed:
		waiting_input = true
		set_text("Press Any Key")