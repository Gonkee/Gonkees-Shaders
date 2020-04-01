extends Node

onready var player = get_parent().get_parent().get_node("KinematicBody")

enum {
	ARG_INT,
	ARG_STRING,
	ARG_BOOL,
	ARG_FLOAT
}

const valid_commands = [
	["set_speed",
		[ARG_FLOAT] ]
]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func set_speed(speed):
	speed = float(speed)
	
	if speed >= 1 and speed <= 5:
		player.speed = speed
		return str("Successfully set speed to ", speed)
	return "Speed value must be between 1 and 5!"
