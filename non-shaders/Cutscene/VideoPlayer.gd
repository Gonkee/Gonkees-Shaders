extends VideoPlayer

onready var fade_class = load("res://cutscene tutorial/Fade.tscn")
var faded_out = false

var aspect_ratio = 16.0/9.0
var vid_length = 4.007

func _ready():
	
	get_tree().set_pause(true)
	
	var vsize = get_viewport_rect().size
	
	get_parent().get_node("ColorRect").set_size(vsize)
	
	if vsize.y < vsize.x / aspect_ratio:
		set_size(Vector2(vsize.y * aspect_ratio, vsize.y))
		set_position(Vector2( (vsize.x - vsize.y * aspect_ratio) / 2, 0))
	else:
		set_size(Vector2(vsize.x, vsize.x / aspect_ratio))
		set_position(Vector2(0, (vsize.y - vsize.x / aspect_ratio) / 2))
	
	set_process(true)

func _process(delta):
	if get_stream_position() >= vid_length - 0.1:
		get_tree().set_pause(false)
		get_parent().queue_free()
		Global.change_scene("res://cutscene tutorial/level_2.tscn")
	
	if get_stream_position() >= vid_length - 0.5 and !faded_out:
		get_parent().add_child(fade_class.instance())
		faded_out = true
