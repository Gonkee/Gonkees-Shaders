extends Node

onready var current_scene = get_tree().get_root().get_child(
			get_tree().get_root().get_child_count() - 1
		)

func _ready():
	pass

func change_scene(path):
	current_scene.queue_free()
	current_scene = load(path).instance()
	get_tree().get_root().add_child(current_scene)

