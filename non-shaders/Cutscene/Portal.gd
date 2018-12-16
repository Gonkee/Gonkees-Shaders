extends Area2D

onready var cutscene_class = load("res://cutscene tutorial/CutscenePlayer.tscn")
onready var fade_class = load("res://cutscene tutorial/Fade.tscn")

func _ready():
	pass

func body_entered(body):
	if body.get_name() == "Player":
		var fade_scene = fade_class.instance()
		fade_scene.connect("finished", self, "load_cutscene")
		get_parent().add_child(fade_scene)

func load_cutscene():
	get_parent().add_child(cutscene_class.instance())