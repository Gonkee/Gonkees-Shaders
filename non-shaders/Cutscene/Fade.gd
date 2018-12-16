extends CanvasLayer

signal finished

onready var Rect = get_node("Rect")

var start_time = 0
var duration = 500

export var fade_in = false

func _ready():
	start_time = OS.get_ticks_msec()
	
	Rect.set_size( Rect.get_viewport_rect().size )
	
	set_process(true)

func set_fade_in(fade_in):
	self.fade_in = fade_in

func _process(delta):
	var alpha = float(OS.get_ticks_msec() - start_time) / duration
	alpha = clamp(alpha, 0, 1)
	
	if alpha == 1:
		emit_signal("finished")
		queue_free()
	
	if fade_in:
		alpha = 1 - alpha
	
	Rect.color.a = alpha
