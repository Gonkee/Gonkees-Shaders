extends KinematicBody

# Gonkee's character control script, from this tutorial series:
# https://www.youtube.com/playlist?list=PLl29vQKblxBVRwG5hVoN_81ierohmNAXu

onready var anim = get_node("AnimationPlayer")
onready var cam = get_node("Camera")
onready var skel = get_node("Armature/Skeleton")
onready var crouchtween = get_node("crouchtween")
onready var raycol = get_node("raycol")
onready var footcast = get_node("footcast")

var headbone
var initial_head_transform

var current_gun = null

var accel = 15
var speed = 16
var vel = Vector3()

var sens = 0.2

var grav = -60
var max_grav = -150

var jump_force = 20

var jumping = false
var crouching = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	headbone = skel.find_bone("head")
	cam.translation = skel.get_bone_global_pose(headbone).origin
	initial_head_transform = skel.get_bone_pose(headbone)
	
	equip("res://Guns/lightning gun.tscn")
	print(current_gun)

func _input(event):
	if event is InputEventMouseMotion:
		var movement = event.relative
		cam.rotation.x += -deg2rad(movement.y * sens)
		cam.rotation.x = clamp(cam.rotation.x, deg2rad(-90), deg2rad(90))
		rotation.y += -deg2rad(movement.x * sens)

func _process(delta):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()
	
	if Input.is_action_just_pressed("shoot"):
		if current_gun and weakref(current_gun):
			current_gun.fire()
	
	if Input.is_action_just_pressed("switch_cam"):
		if cam.current:
			cam.current = false
			get_parent().get_node("Camera").current = true
		else:
			cam.current = true
			get_parent().get_node("Camera").current = false
	
	var target_dir = Vector2(0, 0)
	if Input.is_action_pressed("forward"):
		target_dir.y += 1
	if Input.is_action_pressed("backward"):
		target_dir.y -= 1
	if Input.is_action_pressed("left"):
		target_dir.x += 1
	if Input.is_action_pressed("right"):
		target_dir.x -= 1
	
	if not (jumping or crouching):
		set_anim(target_dir)
	
	target_dir = target_dir.normalized().rotated(-rotation.y)
	
	vel.x = lerp(vel.x, target_dir.x * speed, accel * delta)
	vel.z = lerp(vel.z, target_dir.y * speed, accel * delta)
	
	vel.y += grav * delta
	if vel.y < max_grav:
		vel.y = max_grav
	
	if Input.is_action_pressed("jump") and footcast.is_colliding():
		vel.y = jump_force
		anim.play("idle", 0.1)
		anim.play("jump", 0.1)
		jumping = true
	
	if Input.is_action_pressed("crouch") and not (crouching or jumping):
		anim.play("crouch", 0.1)
		crouchtween.interpolate_property(raycol.shape, "length", raycol.shape.length, 3.2, 0.08, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		crouchtween.interpolate_property(footcast, "translation", footcast.translation, Vector3(0, 2.4, 0), 0.08, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		crouchtween.start()
		crouching = true
	elif (not Input.is_action_pressed("crouch") or jumping) and crouching:
		crouchtween.interpolate_property(raycol.shape, "length", raycol.shape.length, 5, 0.08, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		crouchtween.interpolate_property(footcast, "translation", footcast.translation, Vector3(0, 0.6, 0), 0.08, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		crouchtween.start()
		crouching = false
	
	move_and_slide(vel, Vector3(0, 1, 0))
	
	if is_on_floor() and vel.y < 0:
		vel.y = 0
		jumping = false
	
	var current_head_transform = initial_head_transform.rotated(Vector3(-1, 0, 0), cam.rotation.x)
	skel.set_bone_pose(headbone, current_head_transform)
	
func equip(path):
	if current_gun and weakref(current_gun):
		current_gun.queue_free()
	current_gun = null
	current_gun = load(path).instance()
	cam.add_child(current_gun)
	current_gun.translation = cam.get_node("gunpos").translation

func set_anim(dir):
	if dir == Vector2(0, 0) and anim.current_animation != "idle":
		anim.play("idle", 0.1)
	elif dir == Vector2(0, 1) and not (anim.current_animation == "forward" and anim.get_playing_speed() > 0):
		anim.play("forward", 0.1)
	elif dir == Vector2(1, 1) and not (anim.current_animation == "frontleft" and anim.get_playing_speed() > 0):
		anim.play("frontleft", 0.1)
	elif dir == Vector2(-1, 1) and not (anim.current_animation == "frontright" and anim.get_playing_speed() > 0):
		anim.play("frontright", 0.1)
	elif dir == Vector2(1, 0) and anim.current_animation != "left":
		anim.play("left", 0.1)
	elif dir == Vector2(-1, 0) and anim.current_animation != "right":
		anim.play("right", 0.1)
	elif dir == Vector2(0, -1) and not (anim.current_animation == "forward" and anim.get_playing_speed() < 0):
		anim.play_backwards("forward", 0.1)
	elif dir == Vector2(1, -1) and not (anim.current_animation == "frontright" and anim.get_playing_speed() < 0):
		anim.play_backwards("frontright", 0.1)
	elif dir == Vector2(-1, -1) and not (anim.current_animation == "frontleft" and anim.get_playing_speed() < 0):
		anim.play_backwards("frontleft", 0.1)
